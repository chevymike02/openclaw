# Memory System Architecture

## Overview

A multi-layered memory system for Claude Gateway that provides:
- **Instant capture** (< 60 seconds from thought to storage)
- **Zero loss** (everything archived, nothing deleted)
- **Fast retrieval** (semantic search in < 200ms)
- **Automatic processing** (background consolidation)
- **Token efficient** (only load what's relevant)

## Memory Layers

```
┌─────────────────────────────────────────────────────────────┐
│                        HOT MEMORY                            │
│  Always loaded into context. Current focus areas.           │
│  ~2000 tokens max. Updated frequently.                      │
│                                                              │
│  Files: ~/.claude/memory/hot/                               │
│  - focus.md      (current projects, active decisions)       │
│  - recent.md     (last 24h important items)                 │
│  - pins.md       (manually pinned critical info)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       WARM MEMORY                            │
│  Semantically searchable. Retrieved on demand.              │
│  Summarized chunks with embeddings.                         │
│                                                              │
│  Storage: ~/.claude/memory/warm/                            │
│  - chunks/*.json  (text chunks with metadata)               │
│  - vectors.lance  (LanceDB vector index)                    │
│  - index.json     (chunk metadata index)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       COLD MEMORY                            │
│  Full detail archive. Never deleted. Searchable by time/tag │
│                                                              │
│  Storage: ~/.claude/memory/cold/                            │
│  - YYYY/MM/DD/    (daily directories)                       │
│    - raw/*.md     (original captures, voice dumps)          │
│    - sessions/*.json (full session transcripts)             │
│    - actions/*.json  (tool use logs)                        │
└─────────────────────────────────────────────────────────────┘
```

## Memory CLI Commands

### Capture (Instant, < 60s rule)
```bash
# Voice dump or quick thought - instant capture
memory capture "just had idea about the charity website..."
memory capture --voice  # Start voice recording, transcribe, capture

# Capture with tags for easier retrieval
memory capture --tags "charity,website,idea" "the donation flow should..."
```

### Query (Fast semantic search)
```bash
# Semantic search across warm memory
memory query "what did we decide about the payment system"

# Query with filters
memory query --project "charity-site" "payment integration"
memory query --since "7d" "recent decisions"

# Returns top 5 relevant chunks as JSON
```

### Hot Memory Management
```bash
# View current hot memory
memory hot

# Pin something to hot memory (always loaded)
memory pin "API keys are in 1Password vault 'Dev Keys'"

# Unpin
memory unpin <pin-id>

# Update focus areas
memory focus set "charity-site" "mobile-app" "fitness-tracker"
memory focus add "tax-planning"
memory focus remove "old-project"
```

### Logging (Background, async)
```bash
# Log a decision (queued for processing)
memory log decision "chose Stripe over PayPal for payments because..."

# Log an action
memory log action '{"tool": "Write", "file": "src/payment.ts", ...}'

# Log a learning
memory log learning "React Server Components don't work with..."
```

### Processing (Background service)
```bash
# Process queue (run by daemon)
memory process

# Force reindex warm memory
memory reindex

# Consolidate - move old warm to cold, promote frequent to hot
memory consolidate

# Stats
memory stats
```

## Data Structures

### Capture Entry (Raw)
```json
{
  "id": "cap_20240115_143022_a1b2c3",
  "timestamp": "2024-01-15T14:30:22Z",
  "type": "capture",
  "source": "voice|text|auto",
  "content": "Raw text content...",
  "tags": ["project:charity", "topic:payments"],
  "processed": false
}
```

### Warm Chunk (Processed)
```json
{
  "id": "chunk_abc123",
  "content": "Summarized/chunked content...",
  "embedding": [0.123, -0.456, ...],
  "metadata": {
    "source_ids": ["cap_xyz", "session_123"],
    "created": "2024-01-15T14:30:22Z",
    "last_accessed": "2024-01-20T09:15:00Z",
    "access_count": 5,
    "tags": ["payments", "decisions"],
    "project": "charity-site"
  }
}
```

### Hot Memory Format (focus.md)
```markdown
# Current Focus

## Active Projects
- **charity-site**: Building donation platform. Using Next.js + Stripe.
- **mobile-app**: iOS app for fitness tracking. SwiftUI.

## Recent Decisions
- 2024-01-15: Chose Stripe for payments (lower fees, better API)
- 2024-01-14: Mobile app will sync via CloudKit

## Open Questions
- [ ] Which CDN for charity site images?
- [ ] Heart rate monitor integration approach?

## This Week's Priorities
1. Finish payment integration
2. Set up CI/CD for mobile app
3. Review tax documents with accountant
```

## Hook Integration

### SessionStart Hook
```bash
#!/bin/bash
# Load hot memory into context
cat ~/.claude/memory/hot/focus.md
cat ~/.claude/memory/hot/recent.md
cat ~/.claude/memory/hot/pins.md

# Set environment for other hooks
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export MEMORY_ENABLED=true' >> "$CLAUDE_ENV_FILE"
fi
```

### UserPromptSubmit Hook
```bash
#!/bin/bash
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt')

# Fast semantic search (timeout 3s)
RESULTS=$(timeout 3 memory query --json --limit 3 "$PROMPT" 2>/dev/null)

if [ -n "$RESULTS" ] && [ "$RESULTS" != "[]" ]; then
  echo "## Relevant Memory"
  echo "$RESULTS" | jq -r '.[] | "- \(.content)"'
fi
```

### PostToolUse Hook (Async)
```bash
#!/bin/bash
# Runs in background, doesn't block
INPUT=$(cat)
memory log action "$INPUT" &
exit 0
```

### PreCompact Hook
```bash
#!/bin/bash
# Extract important info before compaction
INPUT=$(cat)

# Get recent decisions and important context from transcript
# Queue for memory processing
memory capture --source "precompact" --auto-extract "$INPUT"
```

### Stop Hook (Async)
```bash
#!/bin/bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')

# Queue session for summarization
memory log session "$SESSION_ID" &
exit 0
```

## Background Service

### Memory Daemon (memoryd)
Runs continuously, processes queues:

```
┌─────────────────────────────────────────────────────────────┐
│                      MEMORY DAEMON                           │
│                                                              │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐                │
│  │ Capture  │   │ Embedding│   │ Consolidate               │
│  │ Queue    │──▶│ Worker   │──▶│ Worker   │                │
│  └──────────┘   └──────────┘   └──────────┘                │
│       │                              │                       │
│       ▼                              ▼                       │
│  ┌──────────┐                  ┌──────────┐                 │
│  │   Cold   │                  │   Warm   │                 │
│  │ Storage  │                  │  Index   │                 │
│  └──────────┘                  └──────────┘                 │
│                                      │                       │
│                                      ▼                       │
│                               ┌──────────┐                  │
│                               │   Hot    │                  │
│                               │ Promote  │                  │
│                               └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

### Processing Pipeline

1. **Capture** → Raw storage (cold/raw/)
2. **Chunk** → Split into semantic chunks
3. **Embed** → Generate vector embeddings
4. **Index** → Add to warm memory index
5. **Classify** → Determine hot/warm/cold based on:
   - Recency (last 24h → potentially hot)
   - Frequency (accessed 5+ times → promote to hot)
   - Relevance to current focus areas
6. **Consolidate** → Merge similar chunks, archive old

## Embedding Strategy

### Local Embeddings (Preferred)
- Model: `sentence-transformers/all-MiniLM-L6-v2`
- Dimension: 384
- Speed: ~10ms per chunk
- Privacy: Everything stays local

### Fallback: API Embeddings
- OpenAI `text-embedding-3-small`
- Only for initial setup or reindexing
- Cached aggressively

## Token Budget

| Layer | Max Tokens | Update Frequency |
|-------|------------|------------------|
| Hot | ~2000 | Every session, on changes |
| Warm (per query) | ~500 | On demand |
| Injected context | ~2500 | Per prompt |

This keeps memory injection under 3k tokens, leaving plenty of room for conversation.

## File Locations

```
~/.claude/
├── memory/
│   ├── hot/
│   │   ├── focus.md
│   │   ├── recent.md
│   │   └── pins.md
│   ├── warm/
│   │   ├── chunks/
│   │   ├── vectors.lance/
│   │   └── index.json
│   ├── cold/
│   │   └── YYYY/MM/DD/
│   ├── queue/
│   │   ├── capture/
│   │   ├── process/
│   │   └── embed/
│   └── config.json
├── hooks/
│   ├── memory-session-start.sh
│   ├── memory-prompt-submit.sh
│   ├── memory-post-tool.sh
│   ├── memory-pre-compact.sh
│   └── memory-stop.sh
└── bin/
    ├── memory          (CLI tool)
    └── memoryd         (background daemon)
```
