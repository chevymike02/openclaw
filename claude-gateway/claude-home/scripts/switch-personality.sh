#!/bin/bash
# switch-personality.sh - Switch active Claude Gateway personality
#
# Usage: switch-personality.sh <personality-name>
# Example: switch-personality.sh finance

set -e

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
PERSONALITIES_DIR="$CLAUDE_HOME/personalities"
ACTIVE_LINK="$CLAUDE_HOME/active-personality"

# Available personalities
AVAILABLE=("dev-lead" "finance" "general")

usage() {
    echo "Usage: $0 <personality>"
    echo ""
    echo "Available personalities:"
    for p in "${AVAILABLE[@]}"; do
        if [[ -L "$ACTIVE_LINK" ]] && [[ "$(readlink "$ACTIVE_LINK")" == *"$p"* ]]; then
            echo "  $p (active)"
        else
            echo "  $p"
        fi
    done
    exit 1
}

# Check arguments
if [[ $# -ne 1 ]]; then
    usage
fi

PERSONALITY="$1"

# Validate personality exists
if [[ ! -d "$PERSONALITIES_DIR/$PERSONALITY" ]]; then
    echo "Error: Personality '$PERSONALITY' not found"
    echo ""
    usage
fi

# Get current personality for comparison
CURRENT=""
if [[ -L "$ACTIVE_LINK" ]]; then
    CURRENT=$(basename "$(readlink "$ACTIVE_LINK")")
fi

# Switch personality
rm -f "$ACTIVE_LINK"
ln -s "$PERSONALITIES_DIR/$PERSONALITY" "$ACTIVE_LINK"

if [[ "$CURRENT" == "$PERSONALITY" ]]; then
    echo "Personality unchanged: $PERSONALITY"
else
    echo "Switched personality: ${CURRENT:-none} -> $PERSONALITY"
fi

# Output for hook integration
echo "$PERSONALITY"
