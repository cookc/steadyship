#!/usr/bin/env bash
# Product checks for the Steadyship plugin repository. Exit non-zero on first failure.
# STEADYSHIP_FULL=1 also runs the generated repo's smoke test (needs Node + Chromium).
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== validate.sh (product) =="
if command -v claude >/dev/null 2>&1; then
  echo "-- plugin manifests"
  claude plugin validate plugin --strict
  claude plugin validate . --strict
else
  echo "-- plugin manifests: skipped (claude CLI not installed)"
fi
echo "-- shell scripts parse"
find scripts plugin tests -name '*.sh' -not -path '*/node_modules/*' -print0 | xargs -0 -n1 bash -n
echo "-- no real names in plugin/"
if grep -rnI "Chris\|cookc" plugin/ | grep -v 'plugin/.claude-plugin/plugin.json'; then
  echo "real-person or account names found in plugin/ (above)"; exit 1
fi
echo "-- templates carry no customer apps"
[ "$(ls plugin/templates/apps)" = "_sample" ] || { echo "plugin/templates/apps must contain only _sample"; exit 1; }
echo "-- template steadyship.md names no business"
if grep '^Business: ' plugin/templates/steadyship.md | grep -v '^Business: {{BUSINESS_NAME}}$'; then
  echo "plugin/templates/steadyship.md names a business (above)"; exit 1
fi
echo "-- placeholders are the allowed nine"
ALLOWED='{{BUSINESS_NAME}} {{GITHUB_OWNER}} {{PLUGIN_MARKETPLACE}} {{REPO_NAME}} {{SETUP_OWNER}} {{SHARED_DRIVE}} {{SPONSOR}} {{TEMPLATE_VERSION}} {{TIME_ZONE}}'
for p in $(grep -rhoE '\{\{[A-Za-z_]+\}\}' plugin/templates | sort -u); do
  case " $ALLOWED " in *" $p "*) ;; *) echo "unexpected placeholder $p"; exit 1;; esac
done
echo "-- CI Playwright pin matches the template lockfile"
PIN="$(sed -n 's/.*playwright@\([0-9][0-9.]*\) install.*/\1/p' .github/workflows/validate.yml | head -1)"
LOCK="$(grep -A1 -m1 '"node_modules/@playwright/test"' plugin/templates/package-lock.json | sed -n 's/.*"version": *"\([^"]*\)".*/\1/p')"
[ -n "$PIN" ] && [ "$PIN" = "$LOCK" ] || { echo "CI pins playwright@$PIN but the template lockfile has $LOCK"; exit 1; }
echo "-- the serve script"
tests/test-serve.sh
echo "-- generate a customer repo and test it"
if [ "${STEADYSHIP_FULL:-0}" = "1" ]; then STEADYSHIP_TEST_SMOKE=1 tests/test-init.sh; else tests/test-init.sh; fi
echo "OK"
