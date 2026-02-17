# Ontoiq Tool Benefits

**Version**: 1.1  
**Created**: 2026-02-13  
**Updated**: 2026-02-14  
**Sources**: YouTube videos + OpenClaw docs

---

## Overview

Ontoiq ใช้ 3 tools หลักที่ทำงานร่วมกัน:

| Tool | Role | Strength |
|------|------|----------|
| **n8n** | Background Automation | Scheduled jobs, API orchestration |
| **OpenClaw** | AI Runtime | Real-time chat, AI reasoning |
| **Obsidian** | Knowledge Workspace (Windows) | Human editing, organization |

---

## n8n - Workflow Automation

### Unique Capabilities

| # | Capability | Description |
|---|------------|-------------|
| 1 | **Scheduled Jobs** | Cron triggers (6 AM daily, weekly reports) |
| 2 | **API Polling** | Fetch from external APIs on schedule |
| 3 | **Multi-service Orchestration** | Chain API calls with transforms |
| 4 | **Error Handling** | Retry logic, fallbacks, error notifications |
| 5 | **Rate Limiting** | Respect API quotas |
| 6 | **Webhook Endpoints** | Receive external callbacks |
| 7 | **Background Processing** | Long-running jobs overnight |

### Use Cases for Ontoiq

| Use Case | Description |
|----------|-------------|
| Daily content ingestion | Fetch YouTube, RSS, Udemy at 6 AM |
| Scheduled publishing | Publish posts at optimal times |
| Analytics collection | Collect metrics daily |
| Embedding pipeline | Generate embeddings for new content |
| Notification layer | Send alerts to Telegram |

### Integration with OpenClaw

**OpenClaw → n8n (trigger workflow)**
```
OpenClaw skill → Webhook → n8n workflow
URL: http://n8n:5678/webhook/ontoiq/...
Headers: X-Webhook-Secret: <secret>
```

**n8n → OpenClaw (send message)**
```json
{
  "method": "POST",
  "url": "http://openclaw:18789/tools/invoke",
  "headers": {
    "Authorization": "Bearer <token>",
    "Content-Type": "application/json"
  },
  "body": {
    "tool": "sessions_send",
    "args": {
      "sessionKey": "agent:main:main",
      "message": "Hello from n8n!"
    }
  }
}
```

---

## OpenClaw - AI Runtime

### Unique Capabilities

| # | Capability | Description |
|---|------------|-------------|
| 1 | **Real-time Chat** | Telegram, WhatsApp, Discord channels |
| 2 | **AI Reasoning** | Content generation, analysis, summarization |
| 3 | **File Manipulation** | Read/write workspace files directly |
| 4 | **Human-AI Co-working** | Collaborate in shared workspace |
| 5 | **Context Awareness** | Reads AGENTS.md, USER.md, memory |
| 6 | **Skill System** | Extend with custom commands |

### Use Cases for Ontoiq

| Use Case | Description |
|----------|-------------|
| Interactive content creation | "สร้าง post เรื่อง Fabric" |
| Content analysis | Extract insights from raw content |
| Draft generation | Create social posts, articles |
| Course creation | Generate modules, lessons |
| Query answering | Search knowledge base |

### System Files (in workspace)

| File | Purpose |
|------|---------|
| `AGENTS.md` | Operating instructions for AI |
| `USER.md` | User context and preferences |
| `SOUL.md` | AI persona and tone |
| `TOOLS.md` | Tool conventions |
| `memory/YYYY-MM-DD.md` | Daily memory logs |

### Integration with n8n

**n8n-webhook skill (built-in)**
```markdown
---
name: n8n-webhook
description: Trigger n8n workflows from OpenClaw
---

User can ask: "trigger workflow X"
OpenClaw calls: http://n8n:5678/webhook/ontoiq/X
```

---

## Obsidian - Knowledge Workspace (Windows Only)

> Obsidian is a desktop application. It runs on the Windows dev machine, **not** on the VPS.
> Files are synced to/from VPS via Mutagen.

### Unique Capabilities

| # | Capability | Description |
|---|------------|-------------|
| 1 | **Knowledge Base** | Organized markdown structure |
| 2 | **Human Editing** | Primary workspace for review (Windows desktop) |
| 3 | **Visualization** | Graph view, backlinks |
| 4 | **Plugin Ecosystem** | Data Files Editor, HTML Reader |
| 5 | **Cross-device Sync** | Mutagen (VPS ↔ Windows) |

### Recommended Plugins

| Plugin | Purpose |
|--------|---------|
| Data Files Editor | Edit JSON/YAML in vault |
| HTML Reader | Render HTML dashboards |

### Ontoiq Vault Structure

```
ontoiq-vault/
├── .openclaw/
│   ├── AGENTS.md          ← AI instructions
│   ├── USER.md            ← User context
│   ├── SOUL.md            ← AI persona
│   └── memory/            ← Daily logs
│
├── 01-Raw-Content/        ← n8n writes (ingestion)
├── 02-Extracts/           ← OpenClaw writes (insights)
├── 03-Drafts/             ← OpenClaw + Human (co-work)
├── 04-Courseware/         ← Course materials
├── 05-Published/          ← Published content
└── 06-Analytics/          ← Metrics (n8n writes)
```

---

## Integration Patterns

### Pattern 1: Content Ingestion

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTENT INGESTION                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   [YouTube API] ──┐                                          │
│   [RSS Feeds] ────┼──→ n8n (scheduled 6 AM)                 │
│   [Udemy API] ────┘         │                               │
│                              ▼                               │
│                    Write to 01-Raw-Content/                  │
│                              │                               │
│                              ▼                               │
│                    Notify OpenClaw                           │
│                              │                               │
│                              ▼                               │
│                    OpenClaw reads new content                │
│                              │                               │
│                              ▼                               │
│                    Extract insights with AI                  │
│                              │                               │
│                              ▼                               │
│                    Write to 02-Extracts/                     │
│                              │                               │
│                              ▼                               │
│                    Mutagen syncs to Windows                 │
│                              │                               │
│                              ▼                               │
│                    Human reviews in Obsidian (Windows)        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Pattern 2: Content Creation

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTENT CREATION                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Human (Telegram): "สร้าง post เรื่อง Fabric"              │
│                              │                               │
│                              ▼                               │
│   OpenClaw reads 02-Extracts/ (find related)                │
│   OpenClaw reads memory/ (context)                          │
│                              │                               │
│                              ▼                               │
│   OpenClaw generates draft with AI                          │
│                              │                               │
│                              ▼                               │
│   Write to 03-Drafts/social-posts/drafts/                   │
│                              │                               │
│                              ▼                               │
│   Mutagen syncs to Windows                                │
│                              │                               │
│                              ▼                               │
│   Human opens Obsidian on Windows, reviews draft             │
│   Human edits, moves to ready/ → syncs back to VPS         │
│                              │                               │
│                              ▼                               │
│   OpenClaw refines based on edits                           │
│                              │                               │
│                              ▼                               │
│   n8n (scheduled) publishes to social                       │
│                              │                               │
│                              ▼                               │
│   Move to 05-Published/                                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Pattern 3: Analytics

```
┌─────────────────────────────────────────────────────────────┐
│                    ANALYTICS COLLECTION                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   n8n (daily midnight)                                       │
│         │                                                    │
│         ├──→ Fetch Twitter metrics                          │
│         ├──→ Fetch LinkedIn metrics                         │
│         ├──→ Aggregate data                                 │
│         │                                                    │
│         ▼                                                    │
│   Write to 06-Analytics/metrics.json                        │
│         │                                                    │
│         ▼                                                    │
│   OpenClaw analyzes trends                                  │
│         │                                                    │
│         ▼                                                    │
│   Generate weekly report                                    │
│         │                                                    │
│         ▼                                                    │
│   Send to Telegram                                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Pattern 4: Course Creation

```
┌─────────────────────────────────────────────────────────────┐
│                    COURSE CREATION                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Human (Telegram): "สร้าง course เรื่อง Power BI DAX"      │
│                              │                               │
│                              ▼                               │
│   OpenClaw searches Qdrant for related content              │
│   OpenClaw reads 02-Extracts/                               │
│                              │                               │
│                              ▼                               │
│   Generate course outline                                   │
│                              │                               │
│                              ▼                               │
│   Write to 04-Courseware/course-outlines/                   │
│                              │                               │
│                              ▼                               │
│   Mutagen syncs → Human reviews in Obsidian (Windows)     │
│                              │                               │
│                              ▼                               │
│   OpenClaw generates modules                                │
│                              │                               │
│                              ▼                               │
│   Write to 04-Courseware/modules/                           │
│                              │                               │
│                              ▼                               │
│   Human reviews on Windows, edits, approves                 │
│                              │                               │
│                              ▼                               │
│   OpenClaw generates lessons                                │
│                              │                               │
│                              ▼                               │
│   Write to 04-Courseware/lessons/                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Tool Responsibilities Summary

| Task | n8n | OpenClaw | Obsidian |
|------|:---:|:--------:|:--------:|
| Fetch YouTube videos | ✅ | | |
| Fetch RSS feeds | ✅ | | |
| Extract insights from content | | ✅ | |
| Generate embeddings | ✅ | ✅ | |
| Create social posts | | ✅ | |
| Schedule posts | ✅ | | |
| Publish to social | ✅ | | |
| Collect analytics | ✅ | | |
| Chat with user | | ✅ | |
| Read/write vault files | | ✅ | |
| Human review/edit | | | ✅ |
| Knowledge organization | | | ✅ |
| Course creation | | ✅ | ✅ |
| Daily notifications | ✅ | | |

---

## Sources

| Source | URL |
|--------|-----|
| OpenClaw + Obsidian video | https://www.youtube.com/watch?v=5_JN4kfr-9o |
| OpenClaw + n8n video | https://www.youtube.com/watch?v=7ekNNMniNrM |
| n8n starter repo | https://github.com/Barty-Bart/openclaw-n8n-starter |
| OpenClaw docs | https://docs.openclaw.ai |
| Skills docs | https://docs.openclaw.ai/tools/skills |
| Agent workspace docs | https://docs.openclaw.ai/concepts/agent-workspace |

---

*Document created: 2026-02-13*
*Updated: 2026-02-14*
