# YouTube Project Research: Insights for OntoIQ Phase B-C

**Research Date**: 2026-02-18  
**Phase**: A — Study References  
**Sources**: Alex McFarland, DEV.to (10 AI Agents), ry-ops RAG blog, n8n templates

---

## 1. Alex McFarland — OpenClaw + Obsidian + n8n Co-Working System

**Source**: Substack + YouTube  
**URL**: https://alexmcfarland.substack.com/p/the-perfect-openclaw-setup-how-i

### Key Concepts

| Concept | Implementation |
|---------|----------------|
| **USER.md** | Single most important file — replaces scattered context profiles |
| **Shared Workspace** | Obsidian synced between human machine + agent machine |
| **Two-Machine Approach** | MacBook (human) + Mac Mini (agent) — co-working feel |
| **Non-Markdown Files** | HTML dashboards, JSON configs, TXT via community plugins |

### Folder Structure Pattern
```
obsidian-vault/
├── System/
│   ├── USER.md          ← Context source of truth
│   ├── AGENTS.md        ← Agent instructions
│   └── memory/          ← Daily logs
├── Content/
│   ├── raw/             ← Ingested content
│   ├── extracts/        ← AI insights
│   └── drafts/          ← Human-AI collaboration
└── Dashboards/
    ├── analytics.html    ← Rendered in Obsidian
    └── stats.json       ← Data files editor plugin
```

### Recommended Obsidian Plugins
- **Data Files Editor** — Edit JSON/YAML in vault
- **HTML Reader** — Render HTML dashboards

### Delegation Framework
> "Start with the overflow, not your best work, and expand from there"

1. Start: Tasks you don't have time for (overflow)
2. Expand: Gradually delegate more creative work
3. Never: Fully automate your best/strategic work

---

## 2. Multi-Agent Architecture — 10 AI Agents Setup

**Source**: DEV.to — "Running 10 AI Agents to Automate My Life"  
**URL**: https://dev.to/linou518/running-10-ai-agents-to-automate-my-life-a-practical-guide-with-openclaw-ki7

### Why Multiple Agents?

| Problem | Solution |
|---------|----------|
| Context bloat | Separate agents = separate context windows |
| Prompt specialization | Different personas per role |
| Fault isolation | One agent down ≠ all agents down |

### Agent Roster (Example)

| Agent | Role | Function |
|-------|------|----------|
| **Joe** | Supervisor | Aggregates reports, main interface |
| **Project A** | Client work | Company A context + schedule |
| **Project B** | Client work | Company B context + schedule |
| **CaiZhi** | Investment | Portfolio monitoring |
| **学思** | Learning | Tech trend curation |
| **(More)** | ... | Specialized by domain |

### Real-World Example: Morning Briefing

```
🌅 Good morning. Here's your briefing for Wednesday, February 12.

📋 Yesterday's Summary
- CaiZhi: Nikkei +1.2%, no major moves
- PJ-A: 2 PR reviews, sprint at 85%
- PJ-B: Staging deployed for demo

📅 Today's Schedule
- 10:00 Company A standup
- 14:00 Company B tech review
- 16:00 Team standup

📰 Top 3 Tech News
- [1] OpenAI new model...
- [2] Rust 2025 Edition...
```

**How it works**:
1. Cron job triggers morning routine
2. `sessions_spawn` requests reports from each Agent
3. Joe aggregates and delivers via Telegram

### Real-World Example: Meeting Conflict Detection

```
⚠️ Meeting conflict detected!
10:00-11:00 Company A Standup
10:30-11:30 Company B Morning Call
→ Suggest rescheduling? [Yes] [No] [Ignore]
```

**How it works**:
1. 5 AM: Fetch calendar via MS Graph API
2. Detect conflicts automatically
3. 2 hours before: Reminder + inline buttons
4. Tap "Yes" → Agent proposes rescheduling

### Real-World Example: Tech Trend Curation

**学思 Agent** runs daily at 4:30 AM:
1. Collect 1,000+ articles from 12 sources (Hacker News, Reddit, arXiv, etc.)
2. AI-powered scoring: relevance × novelty × impact
3. Deliver Top 10 to Telegram
4. Flag OpenClaw-related papers separately

---

## 3. Production Pitfalls (Critical Lessons)

### 🔥 1. Session Contamination
**Symptom**: Agent A's responses come from Agent B
**Cause**: `dmPolicy: pairing` — last bot hijacks all sessions
**Solution**:
```yaml
dmPolicy: allowlist
telegram:
  accounts:
    - name: joe-bot
      binding: agent:main
    - name: caizhi-bot
      binding: agent:caizhi
```

### 🔥 2. Config Disaster
**Symptom**: Gateway won't start
**Cause**: Invalid `streamMode: "full"` (valid: "off"/"partial"/"block")
**Solution**: Always use `config.patch` (validates before applying)
```bash
# ❌ Never do this
vim ~/.openclaw/config.yaml

# ✅ Always use config.patch
openclaw config.patch '{"streamMode": "streaming"}'
```

### 🔥 3. Bot Token Collision
**Rule**: 1 Token = 1 Process
**HA Setup**: Standby node must NOT poll until active

### 🔥 4. Telegram Bot 404
**Symptom**: All bots stop responding
**Cause**: Placeholder `botToken` overwritten real tokens via config.patch
**Lesson**: Never include `botToken` in config.patch — only update bindings/names

### 🔥 5. Model Deprecation
**Symptom**: Agent suddenly stops responding
**Cause**: `model_not_found` (e.g., Claude 3 Opus deprecated)
**Lesson**: Prefer aliases like `anthropic/claude-sonnet-4` over pinned versions

---

## 4. RAG Pipeline Best Practices (n8n + Qdrant)

**Source**: ry-ops blog — "Building a RAG Chatbot with n8n, Qdrant, Claude"  
**URL**: https://ry-ops.dev/posts/2026-02-09-building-a-rag-chatbot-for-my-blog/

### Two-Workflow Architecture

```
┌─────────────────┐     ┌─────────────────┐
│ Indexing Pipeline│     │ Chat Interface  │
├─────────────────┤     ├─────────────────┤
│ 1. Read files   │     │ 1. Chat Trigger │
│ 2. Parse YAML   │     │ 2. AI Agent     │
│ 3. Enrich       │     │ 3. Claude       │
│ 4. Chunk        │     │ 4. Memory (20)  │
│ 5. Embed        │     │ 5. Qdrant tool  │
│ 6. Store        │     │ 6. Embeddings   │
└─────────────────┘     └─────────────────┘
```

### The Stack

| Component | Spec |
|-----------|------|
| n8n | v2.6.3, self-hosted Docker |
| Qdrant | Cloud, 1024-dim Cosine |
| Embeddings | Voyage AI voyage-3 |
| LLM | Claude Sonnet 4.5 |
| Chunk size | 1,500 chars |
| Overlap | 300 chars |
| Retrieval | Top 8 results |

### Content Enrichment (Secret Weapon)

**Problem**: "Here's how to configure workers" — no context about what workers

**Solution**: Prepend metadata before embedding
```javascript
const enrichedContent = 
  'Title: ' + title + '\n' +
  'Category: ' + category + '\n' +
  'Date: ' + date + '\n' +
  'Tags: ' + tags.join(', ') + '\n' +
  'Description: ' + description + '\n\n' +
  body;
```

**Result**: Embeddings capture semantic context → dramatically improves retrieval

### Key Lessons

| Lesson | Details |
|--------|---------|
| Rate limits shape architecture | Design for 3 RPM constraint, not happy path |
| OpenAI-compatible APIs | Swap providers with just URL change |
| Metadata enrichment | Difference between "good enough" and "actually useful" |
| Schema planning | Changing embedding dims = recreate collection |
| Vector dimensions | Plan embedding model BEFORE indexing |

### The Numbers

- 212 blog posts → ~2,500 vector chunks
- 1024-dimensional embeddings
- 2 n8n workflows (6 nodes in chat)
- ~108 minutes indexing (rate-limited)

---

## 5. Implementation for OntoIQ

### Immediate Actions (This Week)

#### A. Multi-Agent Setup
```yaml
# ~/.openclaw/openclaw.yaml
dmPolicy: allowlist
telegram:
  accounts:
    - name: ontoiq-main
      binding: agent:main
    - name: ontoiq-content
      binding: agent:content
    - name: ontoiq-research
      binding: agent:research
```

#### B. Content Enrichment Pipeline
Update n8n embedding workflow:
```javascript
// Before embedding, prepend metadata
const enriched = 
  'Source: ' + $json.source + '\n' +
  'Title: ' + $json.title + '\n' +
  'Type: ' + $json.content_type + '\n\n' +
  $json.content;
```

#### C. Morning Briefing Skill
Create `openclaw-workspace/skills/ontoiq-briefing/SKILL.md`:
```markdown
## When to Use
Cron trigger: 7:00 AM daily

## Workflow
1. Read openclaw-workspace/kanban.md
2. Count posts in ready/ status
3. Count drafts pending
4. Read yesterday's memory
5. Generate Telegram briefing

## Output Format
🌅 OntoIQ Morning Briefing
📊 Status: X ready, Y drafts
📝 Tasks: [list from kanban]
💡 Memory: [key learnings]
```

---

## 6. References

| Source | URL | Priority |
|--------|-----|----------|
| Alex McFarland — OpenClaw + Obsidian | https://alexmcfarland.substack.com | High |
| 10 AI Agents Guide (DEV.to) | https://dev.to/linou518/running-10-ai-agents-to-automate-my-life | High |
| RAG Chatbot Blog (ry-ops) | https://ry-ops.dev/posts/2026-02-09-building-a-rag-chatbot | Medium |
| n8n RAG Template | https://n8n.io/workflows/11468 | Medium |
| OpenClaw Multi-Agent Docs | https://docs.openclaw.ai/concepts/multi-agent | High |

---

*Document created: 2026-02-18*  
*Next: Phase B — Implement n8n Workflows*
