#!/bin/bash
# memory-session-start.sh - Load hot memory at session start
#
# Runs on: SessionStart
# Timing: Sync, should be fast (<500ms)
# Output: Hot memory content (added to Claude's context)

set -e

MEMORY_BIN="${CLAUDE_MEMORY_BIN:-$HOME/.claude/bin/memory}"
MEMORY_HOME="${CLAUDE_MEMORY_HOME:-$HOME/.claude/memory}"

# Initialize if needed
if [[ ! -d "$MEMORY_HOME/hot" ]]; then
    "$MEMORY_BIN" init >/dev/null 2>&1
fi

# Set environment for other hooks
if [[ -n "$CLAUDE_ENV_FILE" ]]; then
    echo "export MEMORY_ENABLED=true" >> "$CLAUDE_ENV_FILE"
    echo "export CLAUDE_MEMORY_HOME=$MEMORY_HOME" >> "$CLAUDE_ENV_FILE"
    echo "export CLAUDE_MEMORY_BIN=$MEMORY_BIN" >> "$CLAUDE_ENV_FILE"
fi

# Output hot memory (becomes part of Claude's context)
echo "## Memory Context"
echo ""

# Focus areas
if [[ -f "$MEMORY_HOME/hot/focus.md" ]]; then
    cat "$MEMORY_HOME/hot/focus.md"
    echo ""
fi

# Pinned items
if [[ -f "$MEMORY_HOME/hot/pins.md" ]] && [[ -s "$MEMORY_HOME/hot/pins.md" ]]; then
    cat "$MEMORY_HOME/hot/pins.md"
    echo ""
fi

# Recent items (last 10 lines)
if [[ -f "$MEMORY_HOME/hot/recent.md" ]] && [[ -s "$MEMORY_HOME/hot/recent.md" ]]; then
    echo "### Recent"
    tail -n 10 "$MEMORY_HOME/hot/recent.md"
    echo ""
fi
