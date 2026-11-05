#!/bin/bash
# entrypoint.sh
# Starts Webots and waits for the world to be fully loaded before starting VSSReferee.
# This avoids the race condition caused by Webots downloading assets at runtime.

set -e

VARIANT="${1:-3v3}"   # "3v3" or "5v5"
MODE="${2:-stable}"   # "stable" or "light"

WEBOTS_LOG="/tmp/webots.log"

if [ "$VARIANT" = "5v5" ]; then
    WORLD_FILE="/vsss_ws/travesim/worlds/Match5v5.wbt"
    REFEREE_FLAG="--5v5"
else
    WORLD_FILE="/vsss_ws/travesim/worlds/Match3v3.wbt"
    REFEREE_FLAG="--3v3"
fi

# Create the log file first so tail -f can open it immediately
touch "$WEBOTS_LOG"

# --- Start Webots in background, writing output directly to the log file ---
# --batch    : suppresses ALL interactive dialogs (theme selector, telemetry, etc.)
# --stdout   : redirects Webots' internal simulation log to process stdout
# --stderr   : redirects Webots' internal error log to process stderr
# Note: we write directly to file (no pipe/tee) to avoid buffering issues that
#       would prevent grep from seeing the output in time.
if [ "$MODE" = "light" ]; then
    xvfb-run -a webots --batch --stdout --stderr --minimize "$WORLD_FILE" >"$WEBOTS_LOG" 2>&1 &
else
    webots --batch --stdout --stderr "$WORLD_FILE" >"$WEBOTS_LOG" 2>&1 &
fi

WEBOTS_PID=$!
echo "[entrypoint] Webots started (PID=$WEBOTS_PID), log: $WEBOTS_LOG"

# Mirror the log file to container stdout in real time (for `docker logs` visibility)
tail -f "$WEBOTS_LOG" &
TAIL_PID=$!

# --- Wait for Webots to finish loading the world ---
# Webots logs "Starting controller" when the world is fully loaded and controllers
# begin launching — this is the earliest reliable signal that the simulation is ready.
MAX_WAIT=120
ELAPSED=0
WEBOTS_READY=0

echo "[entrypoint] Waiting for Webots to finish loading the world (up to ${MAX_WAIT}s)..."

while [ $ELAPSED -lt $MAX_WAIT ]; do
    # Check that Webots is still alive
    if ! kill -0 "$WEBOTS_PID" 2>/dev/null; then
        echo "[entrypoint] ERROR: Webots process died unexpectedly. Last log output:"
        tail -20 "$WEBOTS_LOG" 2>/dev/null || true
        kill "$TAIL_PID" 2>/dev/null || true
        exit 1
    fi

    # "Starting controller" appears as soon as the first robot controller is launched,
    # which only happens after the world has finished loading.
    if grep -q "Starting controller" "$WEBOTS_LOG" 2>/dev/null; then
        WEBOTS_READY=1
        break
    fi

    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

# Stop the background tail now that we're done waiting
kill "$TAIL_PID" 2>/dev/null || true

if [ $WEBOTS_READY -eq 1 ]; then
    echo "[entrypoint] Webots is ready after ${ELAPSED}s. Starting VSSReferee..."
else
    echo "[entrypoint] WARNING: Webots readiness signal not found after ${MAX_WAIT}s. Starting VSSReferee anyway..."
    echo "[entrypoint] --- Last Webots log output ---"
    tail -30 "$WEBOTS_LOG" 2>/dev/null || true
    echo "[entrypoint] --- End of log ---"
fi

# Give Webots a small extra buffer to stabilise
sleep 2

/vsss_ws/VSSReferee/bin/VSSReferee $REFEREE_FLAG --record false
