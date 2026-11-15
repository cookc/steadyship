#!/usr/bin/env bash
# Exercises the generated repository's serve script against a throwaway shared drive:
# static files, read with ETag and byte-order mark handling, write-beside-then-rename,
# If-Match checks, the Excel lock, an unreachable drive, path safety, safety copies,
# a Windows-1252 master, and two serve scripts saving to one master at once.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
command -v node >/dev/null || { echo "test-serve: skipped (no node)"; exit 0; }
OUT="$(mktemp -d "${TMPDIR:-/tmp}/steadyship-serve-test.XXXXXX")"
PID=""
PID2=""
cleanup() { [ -n "$PID" ] && kill "$PID" 2>/dev/null || true; [ -n "$PID2" ] && kill "$PID2" 2>/dev/null || true; rm -rf "$OUT"; }
trap cleanup EXIT
fail() { echo "FAIL: $*"; exit 1; }
DIR="$OUT/repo"; DRIVE="$OUT/drive"
"$ROOT/plugin/scripts/init.sh" "$DIR" --business B --setup-owner S --sponsor P --github-owner g --repo-name r \
  --shared-drive "$DRIVE" --no-git >/dev/null || fail "init"
mkdir -p "$DRIVE" "$DIR/apps/t"
printf '\xEF\xBB\xBFjob,stage\r\nJ-1,Weld\r\n' > "$DRIVE/Jobs.csv"
printf 'name\nAcme\n' > "$DRIVE/Customers.csv"
printf 'secret\n' > "$DRIVE/Payroll.csv"
echo '<!doctype html><title>t</title><script src="../../lib/papaparse.min.js"></script>' > "$DIR/apps/t/index.html"
echo '{"master":"Jobs.csv","reads":["Customers.csv"]}' > "$DIR/apps/t/data.json"
PORT=$(( 20000 + RANDOM % 20000 ))
( cd "$DIR" && STEADYSHIP_LOCK_WAIT_MS=1500 STEADYSHIP_LOCK_STALE_MS=3000 node scripts/serve.mjs t --port "$PORT" --no-open > "$OUT/serve.log" 2>&1 ) &
PID=$!
for i in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$PORT/apps/t/" && break; sleep 0.1; done
U="http://127.0.0.1:$PORT"
code() { curl -s -o "$OUT/body" -w '%{http_code}' "$@"; }
[ "$(code "$U/apps/t/")" = 200 ] || fail "static app page"
[ "$(code "$U/lib/papaparse.min.js")" = 200 ] || fail "lib served"
[ "$(code "$U/steadyship.md")" = 404 ] || fail "repository root must not be served"
[ "$(code "$U/apps/t/../../steadyship.md")" = 404 ] || fail "path traversal"
[ "$(code "$U/api/file/Payroll.csv")" = 404 ] || fail "file not in data.json must be 404"
[ "$(code "$U/api/file/..%2FJobs.csv")" = 404 ] || fail "traversal in api"
curl -s -D "$OUT/h" -o "$OUT/body" "$U/api/file/Jobs.csv"
grep -qi '^etag: "' "$OUT/h" || fail "no ETag on read"
grep -qi '^x-steadyship-writable: yes' "$OUT/h" || fail "master should be writable"
[ "$(head -c 3 "$OUT/body" | od -An -tx1 | tr -d ' ')" != "efbbbf" ] || fail "BOM should be stripped on read"
grep -q '^job,stage' "$OUT/body" || fail "read body"
ETAG="$(grep -i '^etag:' "$OUT/h" | sed 's/^[Ee][Tt][Aa][Gg]: *//; s/\r$//')"
curl -s -D "$OUT/h2" -o /dev/null "$U/api/file/Customers.csv"; grep -qi 'x-steadyship-writable: no' "$OUT/h2" || fail "reads file should be read-only"
[ "$(code -X PUT --data-binary 'x' "$U/api/file/Customers.csv" -H "If-Match: $ETAG")" = 405 ] || fail "PUT to read-only file must be 405"
[ "$(code -X PUT --data-binary 'job,stage\nJ-1,Paint\n' "$U/api/file/Jobs.csv")" = 428 ] || fail "PUT without If-Match must be 428"
[ "$(code -X PUT --data-binary 'x' "$U/api/file/Jobs.csv" -H 'If-Match: "nope"')" = 412 ] || fail "PUT with stale If-Match must be 412"
grep -q 'changed by someone else' "$OUT/body" || fail "412 message"
printf 'job,stage\r\nJ-1,Paint\r\n' > "$OUT/new.csv"
[ "$(code -X PUT --data-binary "@$OUT/new.csv" "$U/api/file/Jobs.csv" -H "If-Match: $ETAG")" = 200 ] || fail "PUT with the right If-Match should succeed: $(cat "$OUT/body")"
[ "$(head -c 3 "$DRIVE/Jobs.csv" | od -An -tx1 | tr -d ' ')" = "efbbbf" ] || fail "BOM should be kept on write"
grep -q 'J-1,Paint' "$DRIVE/Jobs.csv" || fail "write did not land"
ls "$DRIVE" | grep -q 'steadyship-writing' && fail "temp file left behind" || true
# the old ETag is now stale
[ "$(code -X PUT --data-binary "@$OUT/new.csv" "$U/api/file/Jobs.csv" -H "If-Match: $ETAG")" = 412 ] || fail "old ETag must be stale after a write"
# Excel lock file blocks writes
curl -s -D "$OUT/h3" -o /dev/null "$U/api/file/Jobs.csv"; ETAG2="$(grep -i '^etag:' "$OUT/h3" | sed 's/^[Ee][Tt][Aa][Gg]: *//; s/\r$//')"
touch "$DRIVE/~\$Jobs.csv"
[ "$(code -X PUT --data-binary "@$OUT/new.csv" "$U/api/file/Jobs.csv" -H "If-Match: $ETAG2")" = 423 ] || fail "Excel lock must be 423"
grep -q 'open in Excel' "$OUT/body" || fail "423 message"
rm "$DRIVE/~\$Jobs.csv"
# drive gone
mv "$DRIVE" "$DRIVE.away"
[ "$(code "$U/api/file/Jobs.csv")" = 503 ] || fail "unreachable drive must be 503"
grep -q 'not reachable' "$OUT/body" || fail "503 message"
mv "$DRIVE.away" "$DRIVE"
[ "$(code "$U/api/file/Jobs.csv")" = 200 ] || fail "drive back"
# a safety copy of the master as it was is kept before every write; no lock or temp file is left
ls "$DRIVE/steadyship-backups" | grep -q "^Jobs $(date +%Y-%m-%d) start of day.csv$" || fail "no start-of-day copy"
grep -q 'J-1,Weld' "$DRIVE/steadyship-backups/Jobs $(date +%Y-%m-%d) start of day.csv" || fail "start-of-day copy is not the file as it was"
[ -f "$DRIVE/steadyship-backups/Jobs before last change.csv" ] || fail "no before-last-change copy"
ls -A "$DRIVE" | grep -q 'steadyship-lock\|steadyship-writing' && fail "lock or temp file left behind" || true
# an empty save is refused
curl -s -D "$OUT/h4" -o /dev/null "$U/api/file/Jobs.csv"; ETAG3="$(grep -i '^etag:' "$OUT/h4" | sed 's/^[Ee][Tt][Aa][Gg]: *//; s/\r$//')"
[ "$(code -X PUT --data-binary '' "$U/api/file/Jobs.csv" -H "If-Match: $ETAG3")" = 400 ] || fail "empty PUT must be 400"
grep -q 'J-1,Paint' "$DRIVE/Jobs.csv" || fail "empty PUT changed the file"
# a master Excel saved as plain CSV (Windows-1252): read right, and saved back without turning into question marks
cp "$DRIVE/Jobs.csv" "$OUT/Jobs.keep"
printf 'job,stage\r\nJ-2,Caf\xe9 fit-out \x96 \xa3120\r\n' > "$DRIVE/Jobs.csv"
curl -s -D "$OUT/h5" -o "$OUT/body" "$U/api/file/Jobs.csv"
grep -qi '^x-steadyship-encoding: windows-1252' "$OUT/h5" || fail "Windows-1252 master not recognised"
grep -q 'Café fit-out – £120' "$OUT/body" || fail "Windows-1252 master read wrong: $(cat "$OUT/body")"
ETAG4="$(grep -i '^etag:' "$OUT/h5" | sed 's/^[Ee][Tt][Aa][Gg]: *//; s/\r$//')"
[ "$(code -X PUT --data-binary "@$OUT/body" "$U/api/file/Jobs.csv" -H "If-Match: $ETAG4")" = 200 ] || fail "save of a Windows-1252 master: $(cat "$OUT/body")"
[ "$(head -c 3 "$DRIVE/Jobs.csv" | od -An -tx1 | tr -d ' ')" = "efbbbf" ] || fail "converted master should carry a byte-order mark"
grep -q 'Café fit-out – £120' "$DRIVE/Jobs.csv" || fail "accented text lost on save"
grep -q $'\xef\xbf\xbd' "$DRIVE/Jobs.csv" && fail "replacement characters written to the master" || true
cmp -s "$DRIVE/steadyship-backups/Jobs before last change.csv" <(printf 'job,stage\r\nJ-2,Caf\xe9 fit-out \x96 \xa3120\r\n') || fail "safety copy should be the original bytes"
# "Unicode Text" (UTF-16) is refused in plain words, not mangled
printf '\xff\xfej\x00o\x00b\x00' > "$DRIVE/Jobs.csv"
[ "$(code "$U/api/file/Jobs.csv")" = 422 ] || fail "UTF-16 master must be 422"
grep -q 'CSV UTF-8' "$OUT/body" || fail "422 message"
cp "$OUT/Jobs.keep" "$DRIVE/Jobs.csv"
# two computers on one master: a second serve script, both saving at the same instant
PORT2=$((PORT+7))
( cd "$DIR" && node scripts/serve.mjs t --port "$PORT2" --no-open > "$OUT/serve-b.log" 2>&1 ) &
PID2=$!
for i in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$PORT2/apps/t/" && break; sleep 0.1; done
node "$ROOT/tests/serve-race.mjs" "$U" "http://127.0.0.1:$PORT2" "$DRIVE/Jobs.csv" 150 > "$OUT/race.log" 2>&1 || { kill "$PID2" 2>/dev/null; fail "two servers on one master: $(cat "$OUT/race.log")"; }
kill "$PID2" 2>/dev/null || true
ls -A "$DRIVE" | grep -q 'steadyship-lock\|steadyship-writing' && fail "lock or temp file left after concurrent saves" || true
# a lock left by a computer that crashed does not block for ever: the save says so plainly, and a
# later try takes the lock over once it has sat unchanged long enough (times shortened for the test)
echo "dead-pc 1 abc" > "$DRIVE/Jobs.csv.steadyship-lock"
curl -s -D "$OUT/h6" -o /dev/null "$U/api/file/Jobs.csv"; ETAG5="$(grep -i '^etag:' "$OUT/h6" | sed 's/^[Ee][Tt][Aa][Gg]: *//; s/\r$//')"
[ "$(code -X PUT --data-binary "@$OUT/new.csv" "$U/api/file/Jobs.csv" -H "If-Match: $ETAG5")" = 423 ] || fail "held lock must be 423"
grep -q 'Another computer is saving' "$OUT/body" || fail "lock message"
sleep 2
[ "$(code -X PUT --data-binary "@$OUT/new.csv" "$U/api/file/Jobs.csv" -H "If-Match: $ETAG5")" = 200 ] || fail "a lock left by a crash should be taken over: $(cat "$OUT/body")"
[ ! -e "$DRIVE/Jobs.csv.steadyship-lock" ] || fail "taken-over lock left behind"
# the path rules hold for Windows drive roots and network shares
( cd "$DIR" && node scripts/serve.mjs --self-test ) | grep -q 'self-test: OK' || fail "serve self-test"
# a second server on the same port fails plainly
( cd "$DIR" && node scripts/serve.mjs t --port "$PORT" --no-open > "$OUT/serve2.log" 2>&1 ) && fail "second server should fail" || true
grep -q 'already in use' "$OUT/serve2.log" || fail "port-in-use message"
# missing data.json is a plain message
mkdir -p "$DIR/apps/u"; echo '<title>u</title>' > "$DIR/apps/u/index.html"
( cd "$DIR" && node scripts/serve.mjs u --port $((PORT+1)) --no-open > "$OUT/serve3.log" 2>&1 ) && fail "no data.json should fail" || true
grep -q 'data.json is missing' "$OUT/serve3.log" || fail "data.json message"
echo "test-serve: OK"
