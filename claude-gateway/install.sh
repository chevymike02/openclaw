#!/bin/bash
# install.sh - Install Claude Gateway to ~/.claude/
#
# Usage: ./install.sh [--force]
#
# This will:
# 1. Create ~/.claude/ directory structure
# 2. Copy personality files
# 3. Set up scripts and hooks
# 4. Create active-personality symlink

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/claude-home"
TARGET_DIR="${CLAUDE_HOME:-$HOME/.claude}"

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

echo "Claude Gateway Installer"
echo "========================"
echo ""
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Check if target exists
if [[ -d "$TARGET_DIR" ]] && [[ "$FORCE" != "true" ]]; then
    echo "Warning: $TARGET_DIR already exists."
    echo ""
    read -p "Overwrite existing files? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$TARGET_DIR/personalities/_shared"
mkdir -p "$TARGET_DIR/personalities/dev-lead"
mkdir -p "$TARGET_DIR/personalities/finance"
mkdir -p "$TARGET_DIR/personalities/general"
mkdir -p "$TARGET_DIR/scripts"
mkdir -p "$TARGET_DIR/commands"

# Copy files
echo "Copying personality files..."
cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
cp "$SOURCE_DIR/settings.json" "$TARGET_DIR/settings.json"

cp "$SOURCE_DIR/personalities/_shared/"* "$TARGET_DIR/personalities/_shared/"
cp "$SOURCE_DIR/personalities/dev-lead/"* "$TARGET_DIR/personalities/dev-lead/"
cp "$SOURCE_DIR/personalities/finance/"* "$TARGET_DIR/personalities/finance/"
cp "$SOURCE_DIR/personalities/general/"* "$TARGET_DIR/personalities/general/"

# Copy and make scripts executable
echo "Installing scripts..."
cp "$SOURCE_DIR/scripts/"* "$TARGET_DIR/scripts/"
chmod +x "$TARGET_DIR/scripts/"*

# Create active-personality symlink (default to general)
echo "Setting up active personality..."
DEFAULT_PERSONALITY="${CLAUDE_DEFAULT_PERSONALITY:-general}"
rm -f "$TARGET_DIR/active-personality"
ln -s "$TARGET_DIR/personalities/$DEFAULT_PERSONALITY" "$TARGET_DIR/active-personality"

echo ""
echo "Installation complete!"
echo ""
echo "Directory structure:"
echo "  $TARGET_DIR/"
echo "  ├── CLAUDE.md"
echo "  ├── settings.json"
echo "  ├── active-personality -> personalities/$DEFAULT_PERSONALITY"
echo "  ├── personalities/"
echo "  │   ├── _shared/ (SOUL.md, USER.md, MEMORY.md)"
echo "  │   ├── dev-lead/"
echo "  │   ├── finance/"
echo "  │   └── general/"
echo "  └── scripts/"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/personalities/_shared/USER.md with your info"
echo "  2. Customize SOUL.md to match your preferred communication style"
echo "  3. Start Claude Code - it will auto-detect context!"
echo ""
echo "Manual commands:"
echo "  Switch personality: ~/.claude/scripts/switch-personality.sh <name>"
echo "  Available: dev-lead, finance, general"
echo ""
