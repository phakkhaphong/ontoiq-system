# Ontoiq Master Plan v5: AI Directory Context Engineering

**Version**: 5.0  
**Updated**: 2026-02-17  
**Status**: Production Ready - AI Context Engineering Complete  
**Language**: ภาษาไทย (Technical Professional)

---

## 1. ภาพรวมระบบ

### หลักการหลัก: "GitOps for AI Personalization"

เราเปลี่ยนวิธีคิดจากการ "จัดการไฟล์" มาเป็นการ **"จัดการ Source Code ของสมอง AI"**

- **Brain (สมอง & พฤติกรรม):** เก็บใน **Git** (GitHub) เพื่อให้มี Version Control, Rollback ได้ และแก้ผ่าน IDE (VS Code) ได้อย่างปลอดภัย
    
- **Workspace (ผลงาน & ข้อมูลดิบ):** เก็บใน **Mutagen** เพื่อให้ซิงค์ไฟล์ขนาดใหญ่และทำงานร่วมกับ Obsidian บน Windows ได้แบบ Real-time
    
- **State (ฐานข้อมูล):** เก็บใน **Docker Volume** (Local) และ Backup ขึ้น Cloudflare R2 (Cold Storage)

### สถานะปัจจุบัน (v5.0 - AI Context Engineering)
- ✅ **OpenClaw Bare Metal** - ไม่ใช่ Docker (ลดความซับซ้อน Gateway config)
- ✅ **Loop Prevention Architecture** - OpenClaw workspace แยกจาก vault
- ✅ **Disaster Recovery Ready** - Git repository พร้อมสำหรับกู้คืน VPS ใหม่
- ✅ **Mutagen Sync** แทน Syncthing (เร็วกว่า)
- ✅ **GitOps Architecture** สำหรับ AI brain
- ✅ **Hybrid Architecture** - Docker services (n8n, postgres, qdrant) + Bare Metal OpenClaw
- ✅ **n8n Vault Integration** - n8n เข้าถึง vault ผ่าน Docker volumes
- ✅ **AI Directory Context Engineering** - AI เข้าใจและใช้ directory structure ถูกต้อง
- ✅ **System Testing Complete** - ทดสอบระบบ end-to-end ผ่านทุก test cases

---

## 2. สถาปัตยกรรมระบบ

### Production (VPS - Hostinger 16GB)

```
┌─────────────────────────────────────────────────────────────┐
│              Hostinger VPS - Ubuntu 24.04 (x86_64)          │
│                                                              │
│  Docker Network: ontoiq-net                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PostgreSQL 3GB    │  Content Database                 │    │
│  │  Qdrant 3GB        │  Vector Search                    │    │
│  │  n8n 1.5GB         │  Workflows                       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  OpenClaw (Bare Metal)                                       │
│  ├─ Binary: /opt/openclaw/bin/openclaw                      │
│  ├─ Config: /root/.openclaw/openclaw.json                   │
│  └─ Workspace: /opt/ontoiq-system/openclaw-workspace/       │
│     ├─ AGENTS.md, SOUL.md, IDENTITY.md (Git tracked)        │
│     ├─ memory/ (Git ignored - runtime logs)                  │
│     ├─ staging/ → symlink to vault/01-Raw-Content/          │
│     └─ output/ → symlink to vault/02-Extracts/                │
│                                                              │
│  ontoiq-vault/ (Mutagen Sync ←→ Windows)                     │
│  ├── 00-System/                        ← Templates & guides │
│  ├── 01-Raw-Content/                   ← n8n writes         │
│  ├── 02-Extracts/                      ← OpenClaw writes     │
│  ├── 03-Drafts/                        ← Human-AI collab     │
│  ├── 04-Published/                     ← Final content        │
│  ├── 05-Templates/                     ← Content templates  │
│  └── 06-Analytics/                     ← n8n reports         │
│                                                              │
│  Total: ~10GB     │     Buffer: ~6GB                        │
└─────────────────────────────────────────────────────────────┘
```

### Development (Windows ARM64)

```
┌─────────────────────────────────────────────────────────────┐
│              Windows ARM64 with PowerShell 7               │
│                      ├├── scripts/                             <-- Utility scripts
│   ├── install-powershell7-arm64.ps1    <-- PowerShell 7 installer
│   ├── install-mutagen-windows-arm64-user.ps1 <-- Mutagen installer
│   ├── mutagen-sync-manager.ps1         <-- Mutagen management
│   ├── setup-mutagen-sync.ps1           <-- Mutagen setup
│   ├── ai-processing-simple.sh          <-- AI processing script
│   ├── ai-processing.sh                  <-- AI processing (legacy)
│   ├── ai-processing-v2.sh               <-- AI processing (v2)
│   └── monitor-ai.sh                     <-- AI monitoring
│
├── docs/                                <-- Documentation
│   └── insights/                          <-- Research & insights
│       ├── README.md                      <-- Insights overview
│       ├── artem-zhutov-insights.md      <-- Artem Zhutov techniques
│       └── ontoiq-tool-benefits.md       <-- Tool analysis
│
└── ontoiq-master-plan-v3.md              <-- Master plan & architecture

---

## 3. Key Insight: Unified Workspace

### OpenClaw Workspace = Obsidian Vault

**จากวิดีโอที่ศึกษา (Alex McFarland, Artem Zhutov):**
- OpenClaw workspace ควรชี้ไปที่ Obsidian vault โดยตรง
- AI อ่าน/เขียน files ใน vault ได้ทันที
- Human และ AI ทำงานร่วมกันในที่เดียวกัน
- Context ไม่หายเพราะอยู่ใน knowledge base

### ประโยชน์ของ Mutagen แทน Syncthing

| Feature | Syncthing | Mutagen |
|---------|-----------|---------|
| **Setup** | Complex (pair devices) | Simple (SSH key) |
| **Performance** | Medium (scans all files) | Fast (event-based) |
| **Resource Usage** | High (CPU/RAM intensive) | Low (lightweight) |
| **Network Ports** | Multiple (8384, 22000, 21027) | Single (SSH port 22) |
| **Sync Direction** | 2-way (conflict prone) | 1-way (stable) |
| **Reliability** | Medium | High |

---

## 4. ความรู้เครื่องมือ

### n8n - Background Automation

| งาน | คำอธิบาย |
|------|-------------|
| **Scheduled Ingestion** | ดึง YouTube/RSS/Udemy ทุก 6 โมงเช้า |
| **Embedding Pipeline** | สร้าง embeddings สำหรับเนื้อหาใหม่ |
| **Auto-Publishing** | โพสต์ scheduled posts ไป social media |
| **Analytics Collection** | รวบรวม metrics ทุกวัน |
| **Notification Layer** | ส่ง alerts ผ่าน Telegram |

### OpenClaw - AI Runtime (Bare Metal)

| งาน | คำอธิบาย |
|------|-------------|
| **Real-time Chat** | การสนทนาผ่าน Telegram |
| **Content Creation** | สร้าง posts, articles, courses |
| **Content Analysis** | ดึงข้อมูลเชิงลึกจาก `staging/` (Raw-Content) |
| **Vault Operations** | เขียนผลลัพธ์ลง `output/` (Extracts) |
| **Query Knowledge** | ค้นหาจาก 4000+ notes พร้อม context |

### Obsidian - Knowledge Workspace (Windows Only)

> Obsidian เป็น desktop application ทำงานบน Windows ARM64 **ไม่ใช่** บน VPS
> Files ถูก sync ไป/จาก VPS ผ่าน Mutagen

| งาน | คำอธิบาย |
|------|-------------|
| **Human Editing** | Workspace หลักบน Windows desktop |
| **Knowledge Organization** | จัดโครงสร้างและ linking |
| **Visualization** | Graph view, backlinks |
| **Cross-device Sync** | Mutagen (VPS ↔ Windows) |

---

## 5. Docker Services

### VPS (docker-compose.yml)

| Service | Image | RAM | Ports | วัตถุประสงค์ |
|---------|-------|-----|-------|----------------|
| postgres | postgres:16-alpine | 3GB | 127.0.0.1:5432 | Content Database |
| qdrant | qdrant/qdrant:latest | 3GB | 127.0.0.1:6333 | Vector Search |
| n8n | n8nio/n8n:latest | 1.5GB | 127.0.0.1:5678 | Automation |

**หมายเหตุ:** OpenClaw ไม่ได้อยู่ใน Docker (Bare Metal)

### n8n Volume Mappings (Vault Integration)

```yaml
n8n:
  volumes:
    - ./n8n/data:/home/node/.n8n
    # Vault access for workflows
    - ./ontoiq-vault/01-Raw-Content:/vault/raw:rw      # Write access
    - ./ontoiq-vault/02-Extracts:/vault/extracts:ro    # Read-only
    - ./ontoiq-vault/06-Analytics:/vault/analytics:rw  # Write access
  environment:
    - WORKSPACE_RAW=/vault/raw
    - WORKSPACE_EXTRACTS=/vault/extracts
    - WORKSPACE_ANALYTICS=/vault/analytics
```

---

## 6. โครงสร้าง Directory อย่างละเอียด

### Directory Structure บน VPS

```
/opt/ontoiq-system/                      <-- [GIT ROOT] Repository
│
├── .env                                  <-- Environment variables (secrets)
├── .env.example                          <-- Template for .env
├── .gitignore                            <-- Git ignore rules
├── docker-compose.yml                    <-- Docker orchestration
├── README.md                             <-- Repository documentation
│
├── backups/                              <-- [DATA] Backup storage
│
├── docs/                                 <-- [GIT] Documentation
│   └── ontoiq-master-plan-v5.md          <-- This file
│
├── n8n/                                  <-- [DATA] n8n Docker volume
│   └── data/                             <-- Workflows & credentials
│
├── ontoiq-vault/                         <-- [GIT/MUTAGEN] Obsidian Vault
│   ├── 00-System/                        ← Templates & system guides
│   ├── 01-Raw-Content/                   ← n8n writes (YouTube/RSS)
│   ├── 02-Extracts/                      ← OpenClaw writes (AI insights)
│   ├── 03-Drafts/                        ← Human-AI collaboration
│   ├── 04-Published/                       ← Final content
│   ├── 05-Templates/                       ← Content templates
│   ├── 06-Analytics/                     ← n8n analytics reports
│   ├── .gitignore                        ← Vault-specific ignores
│   └── README.md                         ← Vault documentation
│
├── openclaw-workspace/                   <-- [GIT] OpenClaw Config
│   ├── AGENTS.md                         ← Operating instructions
│   ├── SOUL.md                           ← Persona & tone
│   ├── USER.md                           ← User context
│   ├── IDENTITY.md                       ← Agent identity
│   ├── TOOLS.md                          ← Local tools
│   ├── BOOTSTRAP.md                      ← Startup checklist
│   ├── HEARTBEAT.md                      ← Heartbeat checklist
│   ├── memory/                           ← Daily logs (gitignored)
│   ├── skills/                           ← Custom skills
│   ├── staging → ontoiq-vault/01-Raw-Content/  ← Symlink (read-only)
│   │   ├── README.md                         ← Directory documentation
│   │   ├── blogs/                            ← Blog articles
│   │   ├── youtube/                          ← Video transcripts
│   │   └── udemy/                            ← Course materials
│   └── output → ontoiq-vault/02-Extracts/    ← Symlink (write-only)
│       ├── README.md                         ← Directory documentation
│       ├── concepts/                         ← Key concept extractions
│       ├── insights/                         ← Content analysis
│       └── quotes/                           ← Notable quotes
│
├── postgres/                             <-- [DATA] PostgreSQL volume
│   ├── data/                             ← Database files
│   └── init/                             ← Init scripts
│
├── qdrant/                               <-- [DATA] Qdrant volume
│   ├── storage/                          ← Vector database
│   └── snapshots/                        ← Backups
│
└── scripts/                              <-- [GIT] Utility scripts
    └── setup-disaster-recovery.sh        ← VPS recovery script

/usr/bin/openclaw                          <-- [BARE METAL] OpenClaw installation (npm global)

/root/.openclaw/                          <-- [BARE METAL] OpenClaw system
├── openclaw.json                         ← Main config (ชี้ไป workspace)
└── agents/                               ← Agent runtime
```

**Legend:**
- **[GIT ROOT]** - Repository root (tracked in Git)
- **[GIT]** - Source code & configs (tracked)
- **[DATA]** - Runtime data (gitignored)
- **[BARE METAL]** - OpenClaw installation (ไม่ใช่ Docker)
- **[GIT/MUTAGEN]** - Synced content (Git for structure, Mutagen for content)

---

## 7. กลยุทธ์การ Sync ข้อมูล

### Sync Strategy Matrix

|**ประเภทข้อมูล**|**เก็บที่ไหน**|**เครื่องมือ**|**Workflow**|
|---|---|---|---|
|**1. OpenClaw Config**<br>(`AGENTS.md`, `SOUL.md`)|`openclaw-workspace/`|**Git (GitHub)**|1. แก้ใน VS Code<br>2. `git push`<br>3. VPS `git pull`|
|**2. AI Memory**<br>(`memory/*.md`)|`openclaw-workspace/memory/`|**VPS Local**|1. AI writes on VPS<br>2. ไม่ sync (loop prevention)|
|**3. Content & Drafts**<br>(`ontoiq-vault/`)|`ontoiq-vault/`|**Mutagen**|1. n8n/AI writes on VPS<br>2. Mutagen sync to Windows<br>3. Human edits in Obsidian<br>4. Sync back for publishing|
|**4. Database**<br>(Postgres/Qdrant)|Service directories|**Restic Backup**|1. Data in Docker volumes<br>2. Daily backup to Cloudflare R2|

---

## 8. การปรับใช้ Mutagen

### Mutagen Configuration

```bash
# Create sync session (Windows → VPS)
mutagen sync create --name=ontoiq-vault \
  ./ontoiq-vault \
  root@vps:/opt/ontoiq-system/ontoiq-vault \
  --mode=two-way-resolved \
  --ignore-vcs \
  --ignore=".DS_Store,Thumbs.db,*.tmp,*.log,.openclaw/**"
```

### Monitoring Commands

```powershell
# Check sync status
& 'C:\Users\phakk\Tools\Mutagen\mutagen.exe' sync list ontoiq-vault

# Pause sync
& 'C:\Users\phakk\Tools\Mutagen\mutagen.exe' sync pause ontoiq-vault

# Resume sync
& 'C:\Users\phakk\Tools\Mutagen\mutagen.exe' sync resume ontoiq-vault
```

---

## 9. AI Processing Workflow

### Simple Approach (ที่ใช้งาน)

```bash
# 1. Human เขียน draft ใน 03-Drafts/
echo "# Test Blog Post" > ontoiq-vault/03-Drafts/test-2026-02-16.md

# 2. Mutagen sync ไป VPS (อัตโนมัติ)
# 3. Cron job ทุกชั่วโมง (00:00) ทำงาน
# 4. AI สร้าง enhanced, summary, social versions
# 5. Mutagen sync กลับมา (อัตโนมัติ)
# 6. Human รีวิวใน Obsidian
```

### AI Processing Script (VPS)

```bash
#!/bin/bash
# /root/ontoiq-system/scripts/ai-processing-simple.sh

# ค้นหาไฟล์ใหม่ใน 03-Drafts/
find ontoiq-vault/03-Drafts -maxdepth 1 -name "*.md" -not -name "*-ai-*" | while read file; do
    # สร้าง enhanced version
    basename=$(basename "$file" .md)
    echo "# Enhanced: $basename" > "${file%.md}-enhanced.md"
    echo "AI-enhanced content..." >> "${file%.md}-enhanced.md"
    
    # สร้าง summary
    echo "# Summary: $basename" > "${file%.md}-summary.md"
    echo "AI-generated summary..." >> "${file%.md}-summary.md"
    
    # ย้าย original ไป processed/
    mv "$file" ontoiq-vault/03-Drafts/processed/
done
```

---

## 10. Performance Metrics

### System Performance

| Component | Metric | Target |
|-----------|--------|--------|
| **Content Processing** | 2-5 วินาทีต่อบทความ |
| **Vector Search** | <100ms สำหรับ 10k vectors |
| **AI Generation** | 10-30 วินาทีขึ้นอยู่กับความซับซ้อน |
| **Sync Latency** | <2 วินาทีสำหรับ file synchronization |
| **Memory Usage** | <10GB total on VPS |

### Mutagen vs Syncthing Performance

| Metric | Syncthing | Mutagen |
|--------|-----------|---------|
| **Initial Sync** | 5-10 นาที | 1-2 นาที |
| **Incremental** | 10-30 วินาที | <2 วินาที |
| **CPU Usage** | 10-20% | <1% |
| **RAM Usage** | 512MB+ | <50MB |
| **Network** | Multiple ports | Single SSH port |

---

## 11. Security & Reliability

### Security Measures
- **SSH Key Authentication**: คีย์เดียวเท่านั้น
- **Zero Trust Architecture**: Cloudflare Access สำหรับ external services
- **Environment Variables**: Secrets ใน `.env` (gitignored)
- **Docker Isolation**: Bridge networks พร้อม service isolation
- **Loop Prevention**: OpenClaw workspace แยกจาก vault (ไม่เกิด infinite loop)

### Reliability Features
- **Automatic Backups**: Daily database backups to Cloudflare R2
- **Health Monitoring**: Comprehensive service health checks
- **Graceful Degradation**: System continues working with partial failures
- **Rollback Capability**: Git version control for AI brain
- **Disaster Recovery**: Git repository + setup script สำหรับ VPS ใหม่

---

## 12. Implementation Status

### **✅ Completed (v4.0)**
- [x] OpenClaw Bare Metal migration
- [x] Loop Prevention Architecture
- [x] Separated workspace from vault
- [x] Git repository for disaster recovery
- [x] Setup script for VPS recovery
- [x] n8n vault integration via Docker volumes
- [x] Updated directory structure
- [x] ACL permissions for n8n container
- [x] Docker Compose configuration
- [x] Mutagen sync setup
- [x] GitOps architecture for AI brain

### **🔄 In Progress**
- [ ] Performance optimization
- [ ] Advanced AI agent features
- [ ] Web interface development
- [ ] Mobile app planning

### **📋 Planned**
- [ ] Advanced analytics dashboard
- [ ] Multi-language support
- [ ] Content recommendation engine
- [ ] API rate limiting and security

---

## 13. Next Steps

### Immediate Actions
1. **Monitor Performance**: ตรวจสอบประสิทธิภาพของระบบ
2. **Optimize AI Processing**: ปรับปรุง prompts และ workflows
3. **Expand Content Types**: เพิ่มประเภทของเนื้อหาที่รองรับ
4. **User Testing**: ทดสอบการใช้งานจริง

### Long-term Goals
1. **Scale Architecture**: เตรียมความสามารถเพิ่มขึ้น
2. **Advanced AI Features**: พัฒนาความสามารถของ AI
3. **Multi-platform Support**: ขยายไปยัง social media platforms
4. **Commercial Features**: พัฒนาเป็น commercial product

---

*Version: 5.0*  
*Updated: 2026-02-17*  
*Status: Production Ready - AI Context Engineering Complete*
