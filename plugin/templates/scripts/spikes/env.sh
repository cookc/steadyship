#!/usr/bin/env bash
# Environment check: what can this environment do? Reports findings; only a missing git fails it.
set -uo pipefail
cd "$(dirname "$0")/../.." || { echo "RESULT: FAIL could not find the repository folder"; exit 1; }

if ! command -v git >/dev/null 2>&1; then
  echo "missing: git"
  echo "RESULT: FAIL git is missing, so Steadyship's checks cannot run here"
  exit 1
fi

echo "== Tools =="
tools=0
for t in git node npm curl gh python3; do
  # "--version" must actually succeed: Windows ships placeholder python3/python
  # shortcuts that only open the Microsoft Store, and they must not count as present.
  if command -v "$t" >/dev/null 2>&1 && "$t" --version >/dev/null 2>&1; then
    v=$("$t" --version 2>&1 | head -1)
    echo "ok: $t ($v)"; tools=$((tools+1))
  elif command -v "$t" >/dev/null 2>&1; then
    echo "missing: $t (a shortcut exists but it does not run)"
  else
    echo "missing: $t"
  fi
done

echo "== Network =="
net=0; github_ok=0; api_ok=0
probe() { # url -> 0 reachable
  code=$(curl -sS -m 10 -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
  rc=$?
  if [ "$rc" -eq 0 ]; then echo "ok: can reach $1 (HTTP $code)"; return 0; fi
  echo "blocked: cannot reach $1"; return 1
}
if command -v curl >/dev/null 2>&1; then
  probe https://github.com && { net=$((net+1)); github_ok=1; }
  probe https://api.github.com && { net=$((net+1)); api_ok=1; }
  probe https://registry.npmjs.org && net=$((net+1))
  probe https://playwright.azureedge.net && net=$((net+1))
  probe https://cdn.playwright.dev && net=$((net+1))
else
  echo "unknown: network not checked because curl is missing"
fi

echo "== Persistence =="
# Two markers: one in the environment's home (may vanish between sessions),
# one in this repository folder (lives on the user's disk, git-ignored).
# Home present -> survived. Home missing but repo present -> did not survive.
# Both missing -> first run; the answer comes from the next run in a NEW session.
MARK="$HOME/.steadyship-env-marker"
RMARK=".steadyship/env-spike.ran"
if [ -f "$MARK" ]; then
  echo "ok: files in this environment's home survived since $(cat "$MARK")"
  pers=yes
elif [ -f "$RMARK" ]; then
  echo "no: files in this environment's home did NOT survive (first run was $(cat "$RMARK")); tools get reinstalled each session"
  pers=no
  date +%Y-%m-%d > "$MARK" 2>/dev/null || true
else
  if date +%Y-%m-%d > "$MARK" 2>/dev/null; then
    echo "unknown: persistence — first run; run "Check this computer" again in a NEW chat to find out"
    pers=unknown
  else
    echo "unknown: persistence — could not write to $HOME"
    pers=no
  fi
  { mkdir -p .steadyship && date +%Y-%m-%d > "$RMARK"; } 2>/dev/null || true
fi

echo "== GitHub CLI =="
gh=unavailable
if command -v gh >/dev/null 2>&1; then
  echo "ok: gh already present"; gh=present
elif [ "$github_ok" = 1 ] && [ "$api_ok" = 1 ]; then
  arch=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
  exe=""; ext="tar.gz"
  case "$(uname -s)" in
    Darwin) pat="macOS_${arch}\.zip"; ext="zip"; unpack() { unzip -q -o "$1" -d "$2"; } ;;
    MINGW*|MSYS*|CYGWIN*)  # Git Bash on Windows: no unzip, so let PowerShell expand the archive
      pat="windows_${arch}\.zip"; exe=".exe"; ext="zip"   # Expand-Archive refuses any extension but .zip
      unpack() { powershell.exe -NoProfile -Command "Expand-Archive -Force -LiteralPath '$(cygpath -w "$1")' -DestinationPath '$(cygpath -w "$2")'" >/dev/null 2>&1; } ;;
    *)      pat="linux_${arch}\.tar\.gz"; unpack() { tar -xzf "$1" -C "$2"; } ;;
  esac
  tmp=$(mktemp -d)
  url=$(curl -sS -m 60 https://api.github.com/repos/cli/cli/releases/latest 2>/dev/null \
    | grep -o "https://[^\"]*${pat}" | head -1)
  if [ -z "$url" ]; then
    echo "blocked: could not install gh (no download found for $(uname -s)/$arch)"
  elif curl -sSL -m 60 -o "$tmp/gh.$ext" "$url" 2>/dev/null \
    && unpack "$tmp/gh.$ext" "$tmp" 2>/dev/null \
    && mkdir -p "$HOME/.local/bin" \
    && cp "$tmp"/gh_*/bin/gh$exe "$HOME/.local/bin/gh$exe" 2>/dev/null \
    && chmod +x "$HOME/.local/bin/gh$exe"; then
    if "$HOME/.local/bin/gh$exe" --version >/dev/null 2>&1; then
      echo "ok: gh installed to ~/.local/bin (add to PATH)"; gh=installed
    else
      rm -f "$HOME/.local/bin/gh$exe"
      echo "blocked: could not install gh (the downloaded copy does not run on this machine)"
    fi
  else
    echo "blocked: could not install gh (download or unpack failed)"
  fi
  rm -rf "$tmp"
elif [ "$api_ok" = 0 ]; then
  echo "blocked: gh install needs api.github.com"
else
  echo "blocked: gh install needs github.com"
fi

echo "== Working directory =="
echo "ok: working directory is $(pwd)"
if [ -f steadyship.md ]; then echo "ok: steadyship.md is present here"; else echo "missing: steadyship.md is not in this folder"; fi

echo "Environment summary: tools $tools/6, network $net/5, persistence $pers, gh $gh"
echo "RESULT: PASS"
