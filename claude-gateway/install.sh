#!/bin/bash
# install.sh - Install Claude Gateway to ~/.claude/
#
# Usage: ./install.sh [--force]
#
# This will:
# 1. Create ~/.claude/ directory structure
# 2. Copy personality files
# 3. Set up scripts, hooks, and memory CLI
# 4. Initialize memory system
# 5. Create active-personality symlink

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
mkdir -p "$TARGET_DIR/hooks"
mkdir -p "$TARGET_DIR/bin"
mkdir -p "$TARGET_DIR/commands"
mkdir -p "$TARGET_DIR/memory/hot"
mkdir -p "$TARGET_DIR/memory/warm/chunks"
mkdir -p "$TARGET_DIR/memory/cold"
mkdir -p "$TARGET_DIR/memory/queue/capture"
mkdir -p "$TARGET_DIR/memory/queue/process"
mkdir -p "$TARGET_DIR/memory/queue/embed"

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

# Copy and make hooks executable
echo "Installing hooks..."
cp "$SOURCE_DIR/hooks/"* "$TARGET_DIR/hooks/"
chmod +x "$TARGET_DIR/hooks/"*

# Copy and make bin tools executable
echo "Installing memory CLI..."
cp "$SOURCE_DIR/bin/"* "$TARGET_DIR/bin/"
chmod +x "$TARGET_DIR/bin/"*

# Initialize memory system
echo "Initializing memory system..."
"$TARGET_DIR/bin/memory" init

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
echo "  ├── scripts/"
echo "  ├── hooks/"
echo "  ├── bin/"
echo "  │   └── memory (CLI tool)"
echo "  └── memory/"
echo "      ├── hot/    (always loaded)"
echo "      ├── warm/   (searchable)"
echo "      └── cold/   (archived)"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/personalities/_shared/USER.md with your info"
echo "  2. Customize SOUL.md to match your preferred communication style"
echo "  3. Start Claude Code - it will auto-detect context!"
echo ""
echo "Commands:"
echo "  Personality: ~/.claude/scripts/switch-personality.sh <name>"
echo "  Memory:      ~/.claude/bin/memory <command>"
echo ""
echo "Memory commands:"
echo "  memory capture \"thought...\"   Instant capture (<60s rule)"
echo "  memory query \"search...\"      Search warm memory"
echo "  memory hot                     View hot memory"
echo "  memory pin \"important...\"     Pin to hot memory"
echo "  memory stats                   Show statistics"
echo ""
