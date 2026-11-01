#!/usr/bin/env bash
set -euo pipefail

godot --headless --path . --script res://server/authoritative_websocket.gd 2>&1 | tee /tmp/mememom-mm09-server.log || status=$?
status="${status:-0}"
if [[ "$status" -ne 1 ]]; then
  echo "ERROR: expected closed-beta server to fail closed without configuration, got $status" >&2
  exit 1
fi
if grep -Eq "Parse Error|Failed to load script|Compile Error" /tmp/mememom-mm09-server.log; then
  exit 1
fi
grep -q "refuses to start without a valid Canon state" /tmp/mememom-mm09-server.log
godot --headless --path . --script res://tests/prepare_mm09_server_fixture.gd 2>&1 | tee /tmp/mememom-mm09-server-fixture.log
grep -q "MM-09 SERVER FIXTURE READY" /tmp/mememom-mm09-server-fixture.log
public_keys_json="$(node -e 'const fs=require("fs"); process.stdout.write(JSON.stringify({"fixture-key":fs.readFileSync(process.argv[1], "utf8")}))' /tmp/mememom-mm09-public-key.pem)"
MEMEMOM_CANON_PATH='user://mm09-server-tests/canon.json' \
MEMEMOM_BETA_SESSIONS='{"aaaaaaaaaaaaaaaa":"alice","bbbbbbbbbbbbbbbb":"bob"}' \
MEMEMOM_CANON_PUBLIC_KEYS="$public_keys_json" \
MEMEMOM_WS_PORT=19080 \
timeout 2 godot --headless --path . --script res://server/authoritative_websocket.gd 2>&1 | tee /tmp/mememom-mm09-server-live.log || status=$?
status="${status:-0}"
if [[ "$status" -ne 124 ]]; then
  echo "ERROR: expected server smoke timeout after successful bind, got $status" >&2
  exit 1
fi
grep -q "MM-09 closed-beta WebSocket listening on port 19080" /tmp/mememom-mm09-server-live.log
MEMEMOM_CANON_PATH='user://mm09-server-tests/canon.json' \
MEMEMOM_BETA_SESSIONS='{"aaaaaaaaaaaaaaaa":"alice","bbbbbbbbbbbbbbbb":"bob"}' \
MEMEMOM_CANON_PUBLIC_KEYS='{"fixture-key":"not-a-key"}' \
MEMEMOM_WS_PORT=19081 \
godot --headless --path . --script res://server/authoritative_websocket.gd 2>&1 | tee /tmp/mememom-mm09-server-bad-key.log || bad_key_status=$?
bad_key_status="${bad_key_status:-0}"
if [[ "$bad_key_status" -ne 1 ]]; then
  echo "ERROR: signed Canon server did not fail closed on an invalid public key" >&2
  exit 1
fi
grep -q "unverifiable signature" /tmp/mememom-mm09-server-bad-key.log
MEMEMOM_TEST_UNSIGNED_SET=1 godot --headless --path . --script res://tests/prepare_mm09_server_fixture.gd 2>&1 | tee /tmp/mememom-mm09-server-unsigned-fixture.log
grep -q "MM-09 SERVER FIXTURE READY" /tmp/mememom-mm09-server-unsigned-fixture.log
MEMEMOM_CANON_PATH='user://mm09-server-tests/canon.json' \
MEMEMOM_BETA_SESSIONS='{"aaaaaaaaaaaaaaaa":"alice","bbbbbbbbbbbbbbbb":"bob"}' \
MEMEMOM_WS_PORT=19082 \
godot --headless --path . --script res://server/authoritative_websocket.gd 2>&1 | tee /tmp/mememom-mm09-server-unsigned.log || unsigned_status=$?
unsigned_status="${unsigned_status:-0}"
if [[ "$unsigned_status" -ne 1 ]]; then
  echo "ERROR: unsigned Canon server did not fail closed" >&2
  exit 1
fi
grep -q "refuses unsigned Canon set" /tmp/mememom-mm09-server-unsigned.log
echo "MM-09 WebSocket adapter parse/fail-closed/listen gate PASS"
