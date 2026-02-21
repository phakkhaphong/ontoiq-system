# YouTube Project Research: Additional Insights (Phase A Extended)

**Research Date**: 2026-02-18  
**Phase**: A — Extended Study  
**Additional Sources**: Reddit, GitHub, n8n workflows, OpenClaw alternatives

---

## 1. Content Repurposing Factory — YouTube to Social Media

**Source**: Reddit — "I built an n8n content repurposing system"  
**URL**: https://www.reddit.com/r/automation/comments/1lvmfax/  
**YouTube**: https://www.youtube.com/watch?v=u9gwOtjiYnI  
**GitHub Workflow**: https://github.com/lucaswalter/n8n-ai-workflows/blob/main/content_repurposing_factory.json

### Workflow Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Form Trigger   │────▶│  Apify YouTube   │────▶│  Generate       │
│  (YouTube URL)  │     │  Scraper         │     │  Twitter Posts  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                              │                         │
                              ▼                         ▼
                        ┌──────────┐            ┌──────────────┐
                        │ Transcript│            │ LinkedIn     │
                        │ (SRT fmt) │            │ Posts        │
                        └──────────┘            └──────────────┘
```

### Technical Details

| Component | Spec | Cost |
|-----------|------|------|
| **Apify Actor** | `streamers/youtube-scraper` | $5 per 1,000 videos |
| **Endpoint** | `/run-sync-get-dataset-items` | Sync — no polling needed |
| **Output** | Title, metadata, full transcript (SRT) | — |
| **LLM** | Claude Sonnet | — |

### Key Technique: Example-Based Prompting

```
1. Set Field: 8 high-performing tweet examples (curated)
2. Build Master Prompt:
   - Analyze YouTube transcript
   - Study Twitter examples for structure/tone
   - Generate 3 unique viral tweet options
3. LLM Chain Call → Claude Sonnet
4. Format → Share to Slack for review
```

### Extension Possibilities

| Format | Approach |
|--------|----------|
| **Instagram Carousel** | Transcript → extract quotes → generate image |
| **Newsletter Section** | Transcript + URL → mini-promo for newsletter |
| **Blog Post** | Transcript → text-based tutorial |
| **Thread** | Long-form content → Twitter/X thread |

---

## 2. OpenClaw + n8n Stack (Pre-configured Docker)

**Source**: GitHub — `caprihan/openclaw-n8n-stack`  
**URL**: https://github.com/caprihan/openclaw-n8n-stack

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                           │
│  ┌─────────────────┐         ┌─────────────────┐           │
│  │   OpenClaw      │◄───────►│      n8n        │           │
│  │   (AI Agent)    │ webhook │  (Workflows)    │           │
│  │   Port 3456     │         │  Port 5678      │           │
│  └────────┬────────┘         └────────┬────────┘           │
│           │                           │                     │
│           ▼                           ▼                     │
│     ┌──────────┐               ┌──────────┐                │
│     │workspace/│               │workflows/│                │
│     │  (files) │               │ (exports)│                │
│     └──────────┘               └──────────┘                │
│           │                           │                     │
│           ▼                           ▼                     │
│     Anthropic API              External Services            │
│     OpenAI API                 (Slack, Gmail, etc.)          │
│     Google AI API                                           │
└─────────────────────────────────────────────────────────────┘
```

### Included Workflows

- `ripr-chatgpt-validator.json` — Multi-model validation
- `ripr-gemini-validator.json` — Cross-check responses
- `email-triage.json` — AI email sorting
- `social-monitor.json` — Social media monitoring

### Use Cases for OntoIQ

| Use Case | Implementation |
|----------|----------------|
| Email Triage | AI agent reads → summarizes → sends Slack |
| Content Pipeline | research → write → fact-check → publish |
| Social Monitoring | AI-powered responses |
| Automated Reporting | Natural language queries |
| Multi-Model Validation | Claude + ChatGPT + Gemini consensus |

---

## 3. OpenClaw in n8n (Alternative Approach)

**Source**: Reddit — "I rebuilt most of OpenClaw's core functionality in n8n"  
**URL**: https://www.reddit.com/r/n8n/comments/1r24b7c/

### Key Insight

> "I rebuilt most of OpenClaw's core functionality in a single n8n workflow"

### Trade-offs: OpenClaw vs n8n-Only

| Aspect | OpenClaw | n8n-Only |
|--------|----------|----------|
| **Real-time chat** | Native (Telegram/Discord) | Requires chat trigger setup |
| **File operations** | Built-in workspace tools | Execute Command/Read-Write nodes |
| **AI reasoning** | Claude-native | AI Agent node |
| **Memory** | AGENTS.md + memory/ | Custom DB/memory implementation |
| **Skills** | Native skill system | Sub-workflows as "skills" |
| **Setup complexity** | One binary install | Multiple nodes/configs |
| **Flexibility** | Opinionated | Fully customizable |

### Recommendation for OntoIQ

**Keep Hybrid Approach** (OpenClaw + n8n):
- OpenClaw: Real-time chat, content creation, AI reasoning
- n8n: Scheduled workflows, API orchestration, background processing

This matches OntoIQ's current architecture and is more maintainable than n8n-only.

---

## 4. Self-Hosted AI Starter Kit (n8n + Ollama + Qdrant)

**Source**: YouTube + n8n workflows  
**Pattern**: Complete local AI stack

### Stack Components

| Component | Purpose |
|-----------|---------|
| **n8n** | Workflow orchestration |
| **Ollama** | Local LLM inference (Llama, Mistral) |
| **Qdrant** | Vector database |
| **PostgreSQL** | Relational data |

### For OntoIQ Consideration

**Current Stack** (already optimized):
- ✅ n8n (Docker)
- ✅ Qdrant (Docker)
- ✅ PostgreSQL (Docker)
- ✅ OpenClaw (Bare Metal)
- ✅ Cloud LLM APIs (Claude/Kimi)

**No need to switch** to local LLMs unless:
- Cost reduction required
- Privacy requirements change
- Internet connectivity issues

---

## 5. RAG System Patterns from Multiple Sources

### Common Patterns Across Projects

| Pattern | Implementation | Source |
|---------|----------------|--------|
| **Chunking** | 1,500 chars + 300 overlap | ry-ops, n8n templates |
| **Metadata Enrichment** | Prepend Title/Category/Tags | ry-ops blog |
| **Two-Workflow Architecture** | Indexing + Chat | n8n RAG templates |
| **Embedding Model** | OpenAI/voyage-3 (1536/1024 dims) | Multiple |
| **Retrieval Top-K** | 8 results | ry-ops blog |
| **Temperature** | 0.3 for factual accuracy | ry-ops blog |
| **Memory Window** | 20 messages | ry-ops blog |

### OntoIQ Alignment

| Component | Current | Best Practice | Gap |
|-----------|---------|---------------|-----|
| Chunking | ? | 1,500 + 300 overlap | Check/Adjust |
| Metadata | Basic | Enriched (Title+Category+Tags) | Enhance |
| Embeddings | OpenAI | OpenAI/voyage-3 | ✅ Good |
| Top-K | ? | 8 results | Check/Adjust |

---

## 6. Production Hardening Lessons

### From 10 AI Agents Article + Reddit

| Lesson | Details |
|--------|---------|
| **Rate Limits** | Design for 3 RPM constraint, not happy path |
| **Config Management** | Never direct file edit — use `config.patch` |
| **Token Isolation** | 1 Bot Token = 1 Process only |
| **Model Aliases** | Prefer `claude-sonnet-4` over pinned versions |
| **dmPolicy** | Use `allowlist` not `pairing` for multi-bot |
| **Embedding Schema** | Plan dimensions BEFORE indexing |

### For OntoIQ

```yaml
# ~/.openclaw/openclaw.yaml — Recommended Config
dmPolicy: allowlist  # NOT pairing
telegram:
  accounts:
    - name: ontoiq-main
      binding: agent:main
    - name: ontoiq-content
      binding: agent:content

# Updates via:
# openclaw config.patch '{...}'  # ✅ Validated
# NOT: vim ~/.openclaw/config.yaml  # ❌ Risky
```

---

## 7. Content Factory Agent Specialization

### From "9 AI Agents" Pattern

| Agent | Role | Trigger | Output |
|-------|------|---------|--------|
| **Research Agent** | Find sources | Cron / Webhook | Raw content list |
| **Writer Agent** | Create drafts | New raw content | Draft posts |
| **Editor Agent** | Review & refine | Draft ready | Polished content |
| **Publisher Agent** | Schedule & post | Approved content | Published posts |
| **Analytics Agent** | Track performance | Daily cron | Reports |

### For OntoIQ Implementation

```
openclaw-workspace/skills/
├── ontoiq-research/          # Research agent
│   └── SKILL.md
├── ontoiq-writer/            # Writer agent
│   └── SKILL.md
├── ontoiq-editor/              # Editor agent
│   └── SKILL.md
└── ontoiq-publisher/         # Publisher agent (n8n webhook)
    └── SKILL.md
```

---

## 8. Additional References

| Source | URL | Relevance |
|--------|-----|-----------|
| Content Repurposing System | https://github.com/lucaswalter/n8n-ai-workflows | High — YouTube → Social |
| OpenClaw + n8n Stack | https://github.com/caprihan/openclaw-n8n-stack | High — Pre-configured stack |
| YouTube Transcript n8n | https://n8n.io/workflows/2736 | Medium — Apify integration |
| RIP OpenClaw n8n Alternative | https://www.productcompass.pm/p/secure-ai-agent-n8n | Medium — Security approach |
| OpenClaw Alternatives 2026 | https://www.aitooldiscovery.com/guides/openclaw | Medium — Comparison |
| 10 AI Agents Guide | https://dev.to/linou518 | High — Multi-agent patterns |

---

## 9. Action Items for Phase B

### Immediate (This Week)

1. **Review Current n8n Workflows**
   - Check existing workflows in `n8n/workflows/`
   - Identify gaps vs. content repurposing pattern

2. **Implement Content Enrichment**
   - Update embedding pipeline to prepend metadata
   - Add Title, Category, Tags, Description

3. **Configure Multi-Agent (Optional)**
   - Set `dmPolicy: allowlist` if using multiple bots
   - Create separate agent bindings

### Short-term (Next 2 Weeks)

4. **Create ontoiq-research Skill**
   - Trigger: Webhook or Cron
   - Input: Topic or URL
   - Output: Research summary to vault

5. **Create ontoiq-content Skill**
   - Trigger: New content in extracts/
   - Input: Insights + context
   - Output: Draft posts to drafts/

6. **Morning Briefing n8n Workflow**
   - Cron: 7:00 AM daily
   - Read: kanban.md + drafts/ + ready/
   - Output: Telegram summary

---

*Document created: 2026-02-18*  
*Previous: youtube-research-phase-a-c39685.md*  
*Next: Phase B — Implementation*
