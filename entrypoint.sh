#!/bin/bash
# entrypoint.sh
# Starts Webots and waits for the world to be fully loaded before starting VSSReferee.
# This avoids the race condition caused by Webots downloading assets at runtime.

set -e

VARIANT="${1:-3v3}"   # "3v3" or "5v5"
MODE="${2:-stable}"   # "stable" or "light"

if [ "$VARIANT" = "5v5" ]; then
    WORLD_FILE="/vsss_ws/travesim/worlds/Match5v5.wbt"
    REFEREE_FLAG="--5v5"
else
    WORLD_FILE="/vsss_ws/travesim/worlds/Match3v3.wbt"
    REFEREE_FLAG="--3v3"
fi

# --- Start Webots in background ---
# --batch suppresses ALL interactive dialogs (theme selector, telemetry prompts, etc.)
if [ "$MODE" = "light" ]; then
    xvfb-run -a webots --batch --stdout --stderr --minimize "$WORLD_FILE" &
else
    webots --batch "$WORLD_FILE" &
fi

WEBOTS_PID=$!
echo "[entrypoint] Webots started (PID=$WEBOTS_PID)"

# --- Wait for Webots to finish loading the world ---
# We poll the Webots log / process readiness.
# Webots prints "INFO: Simulation started." to stdout once the world is ready.
# As a fallback, we also cap the wait at 120 seconds to avoid hanging forever.
MAX_WAIT=120
ELAPSED=0
WEBOTS_READY=0

echo "[entrypoint] Waiting for Webots to finish loading the world (up to ${MAX_WAIT}s)..."

while [ $ELAPSED -lt $MAX_WAIT ]; do
    # Check that Webots process is still alive
    if ! kill -0 "$WEBOTS_PID" 2>/dev/null; then
        echo "[entrypoint] ERROR: Webots process died unexpectedly. Exiting."
        exit 1
    fi

    # Check for the Webots TCP port (10234 is the default controller port Webots opens)
    # Once it's listening, the world is ready.
    if ss -tlnp 2>/dev/null | grep -q ':10234 '; then
        WEBOTS_READY=1
        break
    fi

    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

if [ $WEBOTS_READY -eq 1 ]; then
    echo "[entrypoint] Webots is ready after ${ELAPSED}s. Starting VSSReferee..."
else
    echo "[entrypoint] WARNING: Webots readiness check timed out after ${MAX_WAIT}s. Starting VSSReferee anyway..."
fi

# Give Webots a small extra buffer to stabilise
sleep 3

/vsss_ws/VSSReferee/bin/VSSReferee $REFEREE_FLAG --record false
