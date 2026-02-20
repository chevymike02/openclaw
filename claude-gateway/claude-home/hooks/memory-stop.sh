#!/bin/bash
# memory-stop.sh - Queue session for summarization (async)
#
# Runs on: Stop
# Timing: Async (doesn't block session end)
# Purpose: Summarize session and update memory classifications

# Check for infinite loop (stop hook active)
INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
    exit 0
fi

MEMORY_BIN="${CLAUDE_MEMORY_BIN:-$HOME/.claude/bin/memory}"

# Get session ID
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Queue session summary (runs in background)
"$MEMORY_BIN" log session "Session $SESSION_ID ended" &

# Process any pending queue items
"$MEMORY_BIN" process >/dev/null 2>&1 &

exit 0
