#!/usr/bin/env bash
# Spike (b): can a script in Claude's VM read and write the shared drive?
# Usage: scripts/spikes/nas-rw.sh <directory on the shared drive>
set -uo pipefail
DIR="${1:-}"
[ -z "$DIR" ] && { echo "RESULT: FAIL no directory given"; exit 1; }
[ -d "$DIR" ] || { echo "RESULT: FAIL directory not visible from the script: $DIR"; exit 1; }
MARK="$DIR/steadyship-spike-$(date +%s).txt"
echo "Listing $DIR ..."; ls -1 "$DIR" | head -5 | sed 's/^/  /'
echo "Writing a test file ..."
echo "steadyship spike $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$MARK" 2>/dev/null || { echo "RESULT: FAIL could read but not write: $DIR"; exit 1; }
echo "Reading it back ..."
grep -q 'steadyship spike' "$MARK" || { echo "RESULT: FAIL wrote a file but could not read it back"; exit 1; }
rm -f "$MARK" || { echo "RESULT: FAIL could not delete the test file (remove $MARK by hand)"; exit 1; }
echo "Read, write and delete all worked."
echo "RESULT: PASS"
