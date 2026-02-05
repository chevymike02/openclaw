#!/bin/bash
# detect-context.sh - Auto-detect personality based on context
#
# Usage: detect-context.sh [prompt]
#
# Checks:
# 1. Current directory (git repo? finance folder?)
# 2. First prompt keywords (if provided)
# 3. Environment variables
#
# Outputs the recommended personality name

set -e

PROMPT="${1:-}"
CWD="${PWD}"

# Default personality
DEFAULT="general"

# --- Directory-based detection ---

detect_from_directory() {
    # Check if in a git repository (likely coding)
    if git rev-parse --git-dir >/dev/null 2>&1; then
        echo "dev-lead"
        return 0
    fi

    # Check for common coding indicators
    if [[ -f "package.json" ]] || [[ -f "Cargo.toml" ]] || [[ -f "go.mod" ]] || \
       [[ -f "requirements.txt" ]] || [[ -f "Makefile" ]] || [[ -f "CMakeLists.txt" ]]; then
        echo "dev-lead"
        return 0
    fi

    # Check for finance-related directory names
    local dir_lower=$(echo "$CWD" | tr '[:upper:]' '[:lower:]')
    if [[ "$dir_lower" == *"finance"* ]] || [[ "$dir_lower" == *"money"* ]] || \
       [[ "$dir_lower" == *"invest"* ]] || [[ "$dir_lower" == *"budget"* ]] || \
       [[ "$dir_lower" == *"tax"* ]]; then
        echo "finance"
        return 0
    fi

    return 1
}

# --- Prompt-based detection ---

detect_from_prompt() {
    local prompt_lower=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

    # Finance keywords
    local finance_keywords="invest stock bond portfolio dividend tax 401k ira roth budget expense savings retirement wealth money finance financial compound interest rate roi"
    for keyword in $finance_keywords; do
        if [[ "$prompt_lower" == *"$keyword"* ]]; then
            echo "finance"
            return 0
        fi
    done

    # Dev keywords
    local dev_keywords="code function class debug error bug fix refactor test deploy git commit push pull merge branch api endpoint database query typescript javascript python rust go docker container kubernetes"
    for keyword in $dev_keywords; do
        if [[ "$prompt_lower" == *"$keyword"* ]]; then
            echo "dev-lead"
            return 0
        fi
    done

    return 1
}

# --- Main detection logic ---

# Priority: Environment override > Prompt > Directory > Default

# 1. Check for explicit override
if [[ -n "${CLAUDE_PERSONALITY:-}" ]]; then
    echo "$CLAUDE_PERSONALITY"
    exit 0
fi

# 2. Check prompt if provided
if [[ -n "$PROMPT" ]]; then
    if result=$(detect_from_prompt); then
        echo "$result"
        exit 0
    fi
fi

# 3. Check directory
if result=$(detect_from_directory); then
    echo "$result"
    exit 0
fi

# 4. Fall back to default
echo "$DEFAULT"
