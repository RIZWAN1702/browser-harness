#!/bin/sh
# Isolated automation Chrome: own profile + debug port, no "Allow remote debugging?" prompt,
# never touches your daily tabs. Chrome 136+ requires a non-default --user-data-dir for the flag.
# The port is unauthenticated: it is bound to loopback only, and the profile dir is 0700.
PORT=${BU_CDP_PORT:-9333}
case "$PORT" in ''|*[!0-9]*) echo "BU_CDP_PORT must be numeric" >&2; exit 1;; esac
PROFILE="$HOME/.browser-harness/chrome"
mkdir -p "$PROFILE" && chmod 700 "$HOME/.browser-harness" "$PROFILE"
curl -s -m 2 "http://127.0.0.1:$PORT/json/version" >/dev/null && exit 0
open -na "Google Chrome" --args --remote-debugging-port="$PORT" --remote-debugging-address=127.0.0.1 \
  --user-data-dir="$PROFILE" --no-first-run about:blank
for i in $(seq 20); do curl -s -m 2 "http://127.0.0.1:$PORT/json/version" >/dev/null && exit 0; sleep 1; done
echo "Chrome debug port $PORT not up" >&2; exit 1
