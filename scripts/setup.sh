#!/usr/bin/env bash
# Steadyship: sets up Claude Code on a Mac or Linux computer with the Steadyship
# plugin. It installs only the plugin; for anything else missing it says what
# to do. Safe to run more than once. Run it with:
#   curl -fsSL https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup.sh | bash
set -uo pipefail
todo=0
ok()   { echo "ok:    $*"; }
note() { echo "note:  $*"; }
todo() { echo "to do: $*"; todo=$((todo+1)); }
runs() { command -v "$1" >/dev/null 2>&1 && "$1" --version >/dev/null 2>&1; }

echo "== Steadyship setup ($(uname -s)) =="
if runs git; then ok "Git ($(git --version))"; else
  case "$(uname -s)" in
    Darwin) todo "install Git: run  xcode-select --install  and accept the prompt" ;;
    *)      todo "install Git with your package manager (Debian/Ubuntu: sudo apt install git; Fedora: sudo dnf install git)" ;;
  esac
fi
if runs node; then ok "Node.js ($(node --version))"
else note "Node.js is not installed; only the tests check (opening an app in a test browser) needs it: https://nodejs.org"; fi

if runs claude; then
  ok "Claude Code ($(claude --version 2>&1 | head -1))"
  if claude plugin marketplace add cookc/steadyship >/dev/null 2>&1 && claude plugin marketplace update steadyship >/dev/null 2>&1; then
    ok "Steadyship marketplace added"
    if claude plugin install steadyship@steadyship >/dev/null 2>&1 && claude plugin update steadyship@steadyship >/dev/null 2>&1; then
      ok "Steadyship plugin installed$(claude plugin list 2>/dev/null | grep -A1 'steadyship@steadyship' | sed -n 's/^ *Version: */ (version /p' | sed 's/$/)/')"
    else
      todo "could not install the plugin; in Claude Code run  /plugin install steadyship@steadyship  and read the message"
    fi
  else
    todo "could not add the marketplace cookc/steadyship (is this computer online, and can it reach github.com?)"
  fi
else
  todo "Claude Code is not installed: install it (https://claude.ai/code) and run this again, or use Claude desktop instead: Customize -> Plugins -> Add marketplace -> cookc/steadyship -> Install steadyship"
fi

echo
echo "== Next =="
echo "Open Claude Code in a new, empty folder and say: Try Steadyship with the demo business"
if [ "$todo" = 0 ]; then echo "RESULT: READY"; else echo "RESULT: $todo thing(s) to do, marked 'to do' above"; fi
