#!/usr/bin/env bash
set -euo pipefail

# CI downloads a versioned Godot executable; local setups may provide `godot` on PATH.
GODOT_CMD="${GODOT_BIN:-godot}"
if ! command -v "$GODOT_CMD" >/dev/null 2>&1; then
  echo "ERROR: Godot executable not found: $GODOT_CMD" >&2
  exit 1
fi

"$GODOT_CMD" --headless --path . --script res://server/authoritative_websocket.gd 2>&1 | tee /tmp/mememom-mm09-server.log || status=$?
status="${status:-0}"
if [[ "$status" -ne 1 ]]; then
  echo "ERROR: expected closed-beta server to fail closed without configuration, got $status" >&2
  exit 1
fi
if grep -Eq "Parse Error|Failed to load script|Compile Error" /tmp/mememom-mm09-server.log; then
  exit 1
fi
grep -q "refuses to start without a valid Canon state" /tmp/mememom-mm09-server.log
"$GODOT_CMD" --headless --path . --script res://tests/prepare_mm09_server_fixture.gd 2>&1 | tee /tmp/mememom-mm09-server-fixture.log
grep -q "MM-09 SERVER FIXTURE READY" /tmp/mememom-mm09-server-fixture.log
MEMEMOM_CANON_PATH='user://mm09-server-tests/canon.json' \
MEMEMOM_BETA_SESSIONS='{"aaaaaaaaaaaaaaaa":"alice","bbbbbbbbbbbbbbbb":"bob"}' \
MEMEMOM_WS_PORT=19080 \
timeout 2 "$GODOT_CMD" --headless --path . --script res://server/authoritative_websocket.gd 2>&1 | tee /tmp/mememom-mm09-server-live.log || status=$?
status="${status:-0}"
if [[ "$status" -ne 124 ]]; then
  echo "ERROR: expected server smoke timeout after successful bind, got $status" >&2
  exit 1
fi
grep -q "MM-09 closed-beta WebSocket listening on port 19080" /tmp/mememom-mm09-server-live.log
echo "MM-09 WebSocket adapter parse/fail-closed/listen gate PASS"
