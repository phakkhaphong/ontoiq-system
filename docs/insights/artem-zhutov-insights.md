# 10 เทคนิคจาก Artem Zhutov สำหรับ OntoIQ System

**Source**: NotebookLM notebook - Artem Zhutov AI OS System  
**Date**: 2026-02-14  
**Project**: OntoIQ System (OpenClaw + Obsidian + n8n)

---

## 1. Separate Workspace Strategy

### แนวคิด
OpenClaw workspace และ Obsidian vault แยกกันอยู่คนละ folder เพื่อความยืดหยุ่นในการจัดการ

### โครงสร้างปัจจุบัน
```
ontoiq-system/
├── ontoiq-vault/                # Obsidian vault (เอกสาร บทความ เนื้อหา)
│   ├── 00-System/
│   ├── 01-Raw-Content/
│   ├── 02-Extracts/
│   └── ...
├── openclaw-workspace/          # OpenClaw workspace (AI context, skills)
│   ├── AGENTS.md
│   ├── BOOTSTRAP.md
│   ├── HEARTBEAT.md
│   ├── IDENTITY.md
│   └── ...
```

### Docker Config
```yaml
openclaw:
  volumes:
    - ./openclaw-workspace:/home/openclaw/.openclaw/workspace
    - ./ontoiq-vault:/home/openclaw/.openclaw/vault  # เข้าถึง vault ได้
```

### Workflow Example
```
1. Human: "สร้าง post เรื่อง Fabric"
2. OpenClaw อ่าน 02-Extracts/ (ใน vault) เพื่อหา context
3. OpenClaw เขียน draft ที่ 03-Drafts/social-posts/drafts/
4. Mutagen syncs to Windows
5. Human เปิด Obsidian บน Windows แก้ไข
6. Human move ไป ready/ → syncs back to VPS
7. n8n publish ตาม schedule
```

### ประโยชน์
- แยก concern: AI context vs เอกสาร/เนื้อหา
- OpenClaw มีพื้นที่ทำงานส่วนตัว (skills, memory)
- Human เห็น AI work ทันทีใน Obsidian (ผ่าน volume mount)
- ง่ายต่อการ backup และ sync

---

## 2. Progressive Disclosure Skills

### แนวคิด
ไม่โหลดทุก skills พร้อมกัน โหลดเฉพาะที่ต้องการใช้ เพื่อประหยัด context window

### Implementation สำหรับ OntoIQ

```
openclaw-workspace/skills/
├── ontoiq-content/
│   └── SKILL.md           # Content creation skill
├── ontoiq-research/
│   └── SKILL.md           # Research skill  
├── ontoiq-course/
│   └── SKILL.md           # Course creation skill
└── ontoiq-analytics/
    └── SKILL.md           # Analytics skill
```

### Skill Example: ontoiq-content/SKILL.md
```markdown
---
name: ontoiq-content
description: Create social media posts and articles
metadata:
  {
    "openclaw": {
      "requires": { "env": ["KIMI_API_KEY"] },
      "user-invocable": true
    }
  }
---

## When to Use
User says: "สร้าง post", "เขียน article", "draft content"

## Workflow
1. Read USER.md for context
2. Search 02-Extracts/ for related content
3. Read memory/ for recent context
4. Generate content with AI
5. Write to 03-Drafts/social-posts/drafts/
6. Notify user via Telegram

## Output Format
- Title
- Hook (first line)
- Body (2-3 paragraphs)
- Call-to-action
- Hashtags

## Quality Checklist
- [ ] Clear value proposition
- [ ] Practical example included
- [ ] Proper Thai grammar
- [ ] Relevant hashtags
```

### ประโยชน์
- Context window ไม่เต็ม
- โหลด skill ตาม task
- ง่ายต่อ maintenance
- Testing แยกได้

---

## 3. Persistent Memory System

### แนวคิด
AI ต้อง "จำ" ข้าม session โดยใช้ files เป็น memory

### Implementation สำหรับ OntoIQ

```
openclaw-workspace/
├── USER.md                # User context (updates when preferences change)
├── SOUL.md                # AI persona (rarely changes)
├── TOOLS.md               # Tool reference (updates when tools change)
├── kanban.md              # Task management
└── memory/
    ├── 2026-02-13.md      # Daily memory
    ├── 2026-02-14.md
    └── ...
```

### Memory File Format
```markdown
# 2026-02-13

## Context Loaded
- Read AGENTS.md, USER.md, SOUL.md
- Read memory/2026-02-12.md (yesterday)

## Tasks Completed
- [x] Created post about Power BI DAX
- [x] Extracted insights from 3 YouTube videos
- [ ] Course outline for Fabric (in progress)

## Content Created
| Type | File | Status |
|------|------|--------|
| Post | ontoiq-vault/03-Drafts/social-posts/drafts/power-bi-dax.md | draft |
| Insight | ontoiq-vault/02-Extracts/insights/fabric-lakehouse.md | done |

## Learned Today
- User prefers Thai for LinkedIn, English for Twitter
- Add practical examples to every post
- Avoid jargon without explanation

## For Tomorrow
- [ ] Complete Fabric course outline
- [ ] Create 2 more social posts
- [ ] Research agentic AI trends

## Errors/Issues
- Qdrant connection timeout (resolved by restart)
```

### Memory Loading Strategy
```markdown
# In AGENTS.md (อยู่ใน openclaw-workspace/)

## Session Start
1. Read today's memory: memory/{YYYY-MM-DD}.md
2. If not exists, read yesterday's
3. Check for pending tasks
4. Load relevant context
```

### ประโยชน์
- AI จำ context ข้าม session
- Track progress ได้
- Learn from mistakes
- ไม่ต้อง repeat instructions

---

## 4. Voice-to-Content Pipeline (Future/Optional)

> **Status**: Not yet implemented. Requires Whisper API integration and custom OpenClaw skill.
> **Dependencies**: OpenAI Whisper API key, n8n workflow for audio processing.
> **Workaround now**: Send text messages via Telegram instead of voice.

### แนวคิด
ใช้เสียงบันทึก ideas แล้ว AI แปลงเป็น content โดยอัตโนมัติ

### Planned Flow (When Implemented)

```
Voice Message (Telegram)
       │
       ▼
n8n receives audio via webhook
       │
       ▼
n8n calls Whisper API to transcribe
       │
       ▼
n8n sends transcript to OpenClaw
       │
       ├──→ Insight → 02-Extracts/
       ├──→ Post draft → 03-Drafts/
       └──→ Task → memory/
       │
       ▼
Confirmation to Telegram
```

### Current Alternative (Text-based)

| Telegram Command | Action |
|------------------|--------|
| "ไอเดีย [content]" | Create insight in 02-Extracts/ |
| "สร้าง post [topic]" | Draft post in 03-Drafts/ |
| "งาน [task]" | Add task to memory |
| "สรุป [topic]" | Research and summarize |

### ประโยชน์ (เมื่อ implement แล้ว)
- บันทึก ideas ได้ทันที
- Hands-free content creation
- เหมาะกับ mobile
- ไม่สูญเสีย ideas

---

## 5. Deep Research Automation

### แนวคิด
AI ทำ research แบบ asynchronous แล้วส่ง report มาให้

### Implementation สำหรับ OntoIQ

```
User (Telegram): "Research agentic AI trends 2026"
       │
       ▼
OpenClaw:
1. Acknowledge: "เริ่ม research แล้ว จะแจ้งผลใน 15 นาที"
2. Trigger n8n workflow
       │
       ▼
n8n Workflow:
1. Search web (Brave API)
2. Scrape top 10 articles
3. Summarize each
4. Generate report
5. Save to 02-Extracts/research/
6. Notify OpenClaw
       │
       ▼
OpenClaw (Telegram):
"Research เสร็จแล้ว สรุป 5 trends หลัก:
1. Multi-agent systems
2. Tool use protocols
3. Long-context models
4. Reasoning improvements
5. Safety frameworks
รายละเอียดที่: 02-Extracts/research/agentic-ai-2026.md"
```

### Research Workflow (n8n)
```yaml
Trigger: Webhook from OpenClaw
Steps:
  - HTTP Request: Brave Search API
  - Loop: For each result
    - HTTP Request: Scrape page
    - AI Summarize: Kimi API
  - Merge: Combine summaries
  - AI Synthesize: Generate trends
  - Write: To vault
  - Webhook: Notify OpenClaw
```

### ประโยชน์
- Offload heavy research
- Asynchronous execution
- Comprehensive results
- Saved for future reference

---

## 6. 24/7 Cron Briefings

### แนวคิด
รับสรุปอัตโนมัติตามเวลา (เช้า/เย็น) ผ่าน Telegram

### Implementation สำหรับ OntoIQ

### Morning Briefing (7:00 AM)
```
n8n (Cron 7:00)
       │
       ▼
Read vault data:
- Pending tasks from memory/
- Draft posts from 03-Drafts/
- New content from 01-Raw-Content/
- Scheduled posts for today
       │
       ▼
OpenClaw generates summary
       │
       ▼
Send to Telegram:
"🌅 สวัสดีตอนเช้า!

📊 สถานะวันนี้:
- Posts พร้อม publish: 3
- Drafts รอแก้: 2
- Content ใหม่: 5 videos

📝 Tasks วันนี้:
- [ ] สร้าง post เรื่อง Fabric
- [ ] แก้ไข draft Power BI

📅 Scheduled:
- 10:00 LinkedIn post about DAX
- 14:00 Twitter thread about ML"
```

### Evening Briefing (9:00 PM)
```
n8n (Cron 21:00)
       │
       ▼
Analyze today's activity:
- Posts published
- Tasks completed
- New insights created
- Analytics summary
       │
       ▼
Send to Telegram:
"🌙 สรุปวันนี้:

✅ Completed:
- 3 posts published
- 5 insights created
- Course outline started

📈 Performance:
- LinkedIn: 234 views, 12 likes
- Twitter: 567 impressions

💡 For Tomorrow:
- Complete Fabric course
- Research agentic AI"
```

### ประโยชน์
- รู้สถานะโดยไม่ต้องเปิดคอม
- Stay on track with goals
- Morning/evening rhythm
- Automated reporting

---

## 7. Human-in-the-Loop via Telegram

### แนวคิด
AI ทำ draft แต่ต้องได้รับ approval จาก human ก่อน publish

### Implementation สำหรับ OntoIQ

```
OpenClaw creates draft
       │
       ▼
Send preview to Telegram:
"📝 Draft post ready:

[#PowerBI] 5 DAX Functions ที่ต้องรู้

DAX (Data Analysis Expressions) เป็นภาษาที่ใช้ใน Power BI...

✅ Approve
❌ Edit
🗑️ Discard"
       │
       ▼
User responds:
- "✅" → Move to ready/, schedule publish
- "แก้เพิ่มเรื่อง..." → Update draft, ask again
- "❌" → Delete draft
```

### Workflow
```yaml
Draft Created:
  - Send preview to Telegram
  - Wait for response (timeout: 1 hour)
  
If Approved:
  - Move to 03-Drafts/social-posts/ready/
  - Trigger n8n to schedule
  
If Edit Requested:
  - Apply edits
  - Send preview again
  
If Timeout:
  - Keep in drafts/
  - Add to evening briefing
```

### ประโยชน์
- Quality control
- ป้องกัน mistakes
- Human oversight
- Flexible editing

---

## 8. Session Log Analysis

### แนวคิด
วิเคราะห์ conversation logs เพื่อปรับปรุง AI performance

### Implementation สำหรับ OntoIQ

```
OpenClaw sessions/
       │
       ▼
Log Analysis (weekly):
1. Collect all session transcripts
2. Identify patterns:
   - Common errors
   - Misunderstandings
   - Successful patterns
3. Generate report
4. Update AGENTS.md
```

### Analysis Output
```markdown
# Session Analysis - Week 6

## Patterns Found

### Errors (12 occurrences)
- Misunderstood "post" vs "article" (5x)
- Created wrong format (4x)
- Missed tags (3x)

### Success Patterns
- Voice → content works well
- Human-in-the-loop improves quality
- Morning briefings increase productivity

## Recommendations
1. Add format examples to AGENTS.md
2. Create skill for post vs article
3. Auto-suggest tags based on content

## AGENTS.md Updates
- Added: Format examples section
- Added: Post vs article decision tree
- Added: Tag suggestion rules
```

### ประโยชน์
- Continuous improvement
- Learn from mistakes
- Data-driven optimization
- Prevent recurring errors

---

## 9. Kanban-Based Task Management

### แนวคิด
ใช้ Kanban board ใน Obsidian เพื่อให้ AI เข้าใจ workflow

### Implementation สำหรับ OntoIQ

```
openclaw-workspace/
└── kanban.md
```

### kanban.md
```markdown
# OntoIQ Task Board

## 📥 Inbox
- [ ] Research agentic AI frameworks
- [ ] Create post about Fabric Lakehouse

## 📝 In Progress
- [ ] Course: Power BI DAX Basics
- [ ] Article: 2026 Data Trends

## 👀 Review
- [ ] Post: 5 DAX Functions
- [ ] Carousel: Fabric Overview

## ✅ Done
- [x] Setup OpenClaw workspace
- [x] Create system files

## 📅 Scheduled
- 2026-02-14: Publish DAX post
- 2026-02-15: Complete course outline
```

### AI Interaction
```
User: "มีอะไรต้องทำบ้าง"
OpenClaw:
- Read openclaw-workspace/kanban.md
- Parse tasks by status
- Reply with summary

User: "ย้าย DAX post ไป review"
OpenClaw:
- Update openclaw-workspace/kanban.md
- Move task to Review column
- Confirm change
```

### ประโยชน์
- Visual workflow
- AI understands priority
- Easy status tracking
- Human + AI collaboration

---

## 10. Efficient File Operations via OpenClaw Tools

### แนวคิด
ใช้ OpenClaw built-in tools (read, write, edit) แทนการแก้ไฟล์ทั้งไฟล์ เพื่อประหยัด tokens

> Note: Obsidian ไม่มี official CLI. การจัดการไฟล์ทำผ่าน OpenClaw tools โดยตรง.

### Implementation สำหรับ OntoIQ

### Common Operations via OpenClaw Tools
```
# Read file
read_file("03-Drafts/post.md")

# Write new file
write_file("02-Extracts/insights/new-insight.md", content)

# Edit specific section
edit_file("03-Drafts/post.md", search="status: draft", replace="status: ready")

# Search files
search_files("02-Extracts/", query="Power BI")
```

### Benefits vs Full File Rewrite
| Operation | Full Rewrite | Targeted Edit |
|-----------|-------------|---------------|
| Update status | Read → Rewrite all → Save | edit_file (1 call) |
| Add tag | Read → Parse → Rewrite → Save | edit_file (1 call) |
| Search content | Read all files | search_files (1 call) |

### ประโยชน์
- ประหยัด tokens
- ลด errors
- เร็วกว่า
- ใช้ built-in tools ที่มีอยู่แล้ว

---

## Implementation Priority

| Priority | Technique | Effort | Impact | Phase |
|----------|-----------|--------|--------|-------|
| **1** | Separate Workspaces | Low | High | ✅ Done |
| **2** | Persistent Memory | Low | High | ✅ Done |
| **3** | Human-in-the-Loop | Medium | High | Week 5 |
| **4** | Cron Briefings | Medium | Medium | Week 5 |
| **5** | Progressive Skills | Medium | Medium | Week 5 |
| **6** | Voice Pipeline | High | High | Future/Optional |
| **7** | Deep Research | High | Medium | Week 6+ |
| **8** | Kanban Tasks | Low | Medium | Week 4 |
| **9** | Session Analysis | Medium | Low | Week 7 |
| **10** | File Operations (OpenClaw Tools) | Low | Medium | Week 4 |

---

## Checklist

### Phase 1 (Done)
- [x] Separate workspace config in docker-compose.yml
- [x] OpenClaw workspace files created (AGENTS.md, BOOTSTRAP.md, HEARTBEAT.md, IDENTITY.md)
- [x] System files in openclaw-workspace/ (USER.md, SOUL.md, TOOLS.md)
- [x] Memory directory created in openclaw-workspace/
- [x] Initial memory file created
- [x] Ontoiq vault structure maintained for content

### Phase 2 (Week 4-5)
- [ ] Create Kanban board in openclaw-workspace/kanban.md
- [ ] Create ontoiq-content skill
- [ ] Create ontoiq-research skill
- [ ] Implement human-in-the-loop workflow
- [ ] Setup morning/evening briefings in n8n

### Phase 3 (Week 6+)
- [ ] Create deep research workflow
- [ ] Setup session log analysis

### Future/Optional
- [ ] Setup Whisper API for voice transcription
- [ ] Implement voice-to-content pipeline

---

## Sources
- Artem Zhutov YouTube: https://www.youtube.com/@ArtemXTech
- OpenClaw + 4000 Notes: https://www.youtube.com/watch?v=ZdZUNwUwHIs
- Claude Code + Obsidian: https://www.youtube.com/watch?v=jRjFYq-SEUk
- GitHub: https://github.com/ArtemXTech
- Substack: https://artemxtech.substack.com

---

*Document created: 2026-02-13*
*Last updated: 2026-02-14*
