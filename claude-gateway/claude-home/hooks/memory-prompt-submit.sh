#!/bin/bash
# memory-prompt-submit.sh - Query memory based on user prompt
#
# Runs on: UserPromptSubmit
# Timing: Sync, must be fast (<3s timeout)
# Output: Relevant memory context (added to Claude's context)

# Read input from stdin
INPUT=$(cat)

# Extract prompt
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if [[ -z "$PROMPT" ]]; then
    exit 0
fi

MEMORY_BIN="${CLAUDE_MEMORY_BIN:-$HOME/.claude/bin/memory}"

# Skip memory query for very short prompts or common commands
if [[ ${#PROMPT} -lt 10 ]]; then
    exit 0
fi

# Skip for common non-memory prompts
case "$PROMPT" in
    "y"|"n"|"yes"|"no"|"ok"|"continue"|"stop"|"quit"|"exit")
        exit 0
        ;;
esac

# Query memory with timeout (3 seconds max)
RESULTS=$(timeout 3 "$MEMORY_BIN" query --json --limit 3 "$PROMPT" 2>/dev/null || echo "[]")

# Only output if we have results
if [[ "$RESULTS" != "[]" ]] && [[ -n "$RESULTS" ]]; then
    # Check if results array is not empty
    RESULT_COUNT=$(echo "$RESULTS" | jq 'length' 2>/dev/null || echo "0")

    if [[ "$RESULT_COUNT" -gt 0 ]]; then
        echo ""
        echo "## Relevant Memory"
        echo "$RESULTS" | jq -r '.[] | "- [\(.timestamp // "unknown")] \(.content // "")"' 2>/dev/null | head -n 10
        echo ""
    fi
fi

exit 0
