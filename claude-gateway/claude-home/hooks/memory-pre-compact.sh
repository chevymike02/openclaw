#!/bin/bash
# memory-pre-compact.sh - Extract important context before compaction
#
# Runs on: PreCompact
# Timing: Sync (critical - must complete before compaction)
# Purpose: Save important decisions/context that would be lost

# Read input from stdin (contains session info)
INPUT=$(cat)

MEMORY_BIN="${CLAUDE_MEMORY_BIN:-$HOME/.claude/bin/memory}"
MEMORY_HOME="${CLAUDE_MEMORY_HOME:-$HOME/.claude/memory}"

# Get session transcript path if available
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
    # Extract recent important items from transcript
    # Look for decisions, conclusions, action items

    # Get last 50 lines of transcript for analysis
    RECENT_CONTEXT=$(tail -n 50 "$TRANSCRIPT_PATH" 2>/dev/null | head -c 10000)

    if [[ -n "$RECENT_CONTEXT" ]]; then
        # Save pre-compaction snapshot
        "$MEMORY_BIN" capture --source "precompact" --tags "auto,precompact" \
            "Pre-compaction snapshot: $RECENT_CONTEXT" >/dev/null 2>&1 &
    fi
fi

# Also capture current timestamp for continuity
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "- [$TIMESTAMP] Context compaction occurred" >> "$MEMORY_HOME/hot/recent.md"

# Output reminder for Claude
echo ""
echo "## Memory Note"
echo "Context was compacted. Hot memory and recent captures preserved."
echo "If important context was lost, check: memory query \"<topic>\""
echo ""

exit 0
