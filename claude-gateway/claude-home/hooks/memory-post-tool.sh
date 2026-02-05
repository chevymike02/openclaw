#!/bin/bash
# memory-post-tool.sh - Log tool actions (async, non-blocking)
#
# Runs on: PostToolUse
# Timing: Async (doesn't block Claude)
# Purpose: Build action history in cold storage

# Read input from stdin
INPUT=$(cat)

MEMORY_BIN="${CLAUDE_MEMORY_BIN:-$HOME/.claude/bin/memory}"

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

# Log significant actions only
case "$TOOL_NAME" in
    Write|Edit)
        # Log file modifications
        FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // "unknown"')
        "$MEMORY_BIN" log action "Modified file: $FILE_PATH" &
        ;;
    Bash)
        # Log meaningful bash commands (not just ls, cd, etc.)
        COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
        case "$COMMAND" in
            ls*|cd*|pwd|echo*|cat*)
                # Skip trivial commands
                ;;
            git\ commit*|git\ push*|npm\ *|pnpm\ *|docker\ *)
                # Log significant commands
                "$MEMORY_BIN" log action "Ran command: $COMMAND" &
                ;;
        esac
        ;;
    Task)
        # Log task delegations
        DESC=$(echo "$INPUT" | jq -r '.tool_input.description // "unknown task"')
        "$MEMORY_BIN" log action "Delegated task: $DESC" &
        ;;
esac

exit 0
