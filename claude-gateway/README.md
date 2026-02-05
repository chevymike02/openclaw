# Claude Gateway - Personal AI Orchestration System

A personal AI orchestration layer built on top of Claude Code, enabling dynamic personality switching, persistent memory, and multi-device access.

## Vision

Turn Claude Code into your personal AI team orchestrator:

- **Dynamic Personalities** - Automatically switch between expert personas based on context
- **Persistent Memory** - Maintain long-term knowledge across sessions
- **Multi-Device Access** - Run on multiple machines via Tailscale
- **Frontend Interface** - Web UI for managing your AI team (planned)
- **Mobile App** - Access your AI team on the go (planned)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Devices (Tailscale)                  │
│   MacBook ──── Desktop ──── Phone ──── Tablet               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Claude Gateway (Host)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Dev Lead   │  │   Finance   │  │   General   │  ...    │
│  │  Personality│  │  Personality│  │  Personality│         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                              │                               │
│                    Shared Context                            │
│            (SOUL · USER · MEMORY)                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Claude Code CLI                         │
│              (via Anthropic API / Claude Max)               │
└─────────────────────────────────────────────────────────────┘
```

## File Structure

```
~/.claude/
├── CLAUDE.md                        ← Main loader with @imports
├── active-personality -> personalities/dev-lead/  ← Symlink
│
├── personalities/
│   ├── _shared/                     ← Shared across all personalities
│   │   ├── SOUL.md                  ← Core values, ethics, communication style
│   │   ├── USER.md                  ← About Mike (preferences, context)
│   │   └── MEMORY.md                ← Long-term facts, decisions, learnings
│   │
│   ├── dev-lead/
│   │   ├── IDENTITY.md              ← Senior Dev Lead persona
│   │   └── EXPERTISE.md             ← Tech stack, coding patterns, architecture
│   │
│   ├── finance/
│   │   ├── IDENTITY.md              ← Finance Advisor persona
│   │   └── EXPERTISE.md             ← Investment strategies, tax optimization
│   │
│   └── general/
│       ├── IDENTITY.md              ← General assistant
│       └── EXPERTISE.md             ← Broad knowledge base
│
├── scripts/
│   ├── switch-personality.sh        ← Manual personality switching
│   └── detect-context.sh            ← Auto-detect context from prompt/directory
│
├── commands/
│   └── personality.md               ← /personality slash command
│
└── settings.json                    ← Hooks for auto-switching
```

## Quick Start

```bash
# Install to ~/.claude/
./install.sh

# Switch personality manually
~/.claude/scripts/switch-personality.sh finance

# Or just start Claude Code - it auto-detects context
claude
```

## Personalities

### Dev Lead
- Senior software engineer perspective
- Code review, architecture decisions, debugging
- Activates in: git repos, coding projects, when discussing code

### Finance
- Financial advisor perspective
- Investment analysis, tax strategies, budgeting
- Activates in: finance directories, when discussing money/investments

### General
- Balanced generalist
- Research, writing, planning, general questions
- Default fallback when no specific context detected

## Adding New Personalities

1. Create directory: `~/.claude/personalities/my-persona/`
2. Add `IDENTITY.md` - Who is this persona?
3. Add `EXPERTISE.md` - What do they know?
4. Update `detect-context.sh` with trigger conditions

## Roadmap

### Phase 1: Foundation (Current)
- [x] Personality file structure
- [x] CLAUDE.md with dynamic imports
- [x] Context detection scripts
- [x] SessionStart hooks
- [ ] Manual switching command

### Phase 2: Intelligence
- [ ] Smarter context detection (NLP on prompts)
- [ ] Memory consolidation (auto-update MEMORY.md)
- [ ] Cross-session learning summaries
- [ ] Personality blending (e.g., 70% dev + 30% finance)

### Phase 3: Multi-Device (Tailscale)
- [ ] Central host configuration
- [ ] Sync personalities across devices
- [ ] Shared memory store
- [ ] Device-specific overrides

### Phase 4: Frontend
- [ ] Web UI for personality management
- [ ] Session history browser
- [ ] Memory editor
- [ ] Real-time personality switching

### Phase 5: Mobile
- [ ] iOS app (connects to gateway host)
- [ ] Android app
- [ ] Voice interface
- [ ] Push notifications

## Configuration

### Environment Variables

```bash
CLAUDE_GATEWAY_HOST=100.x.x.x    # Tailscale IP of main host
CLAUDE_DEFAULT_PERSONALITY=general
CLAUDE_AUTO_SWITCH=true          # Enable auto personality detection
```

### Hooks

The system uses Claude Code hooks for automatic behavior:

- **SessionStart**: Detect context, switch personality, inject reminders
- **UserPromptSubmit**: Analyze prompt for personality hints
- **Stop**: Optionally update MEMORY.md with session learnings

## Philosophy

This system follows OpenClaw's insight:

> "Each session, you wake up fresh. These files ARE your memory."

The model doesn't persist between sessions. Files are the memory. Consistency comes from:
1. Well-defined personality files loaded every session
2. Shared context (SOUL, USER, MEMORY) across all personas
3. Automatic context detection to load the right expert

---

Built by Mike, powered by Claude Code.
