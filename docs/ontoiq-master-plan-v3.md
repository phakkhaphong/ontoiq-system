# Ontoiq Master Plan v3: GitOps for AI Personalization

**Version**: 3.0  
**Updated**: 2026-02-16  
**Status**: Production Ready  
**Language**: ภาษาไทย (Technical Professional)

---

## 1. ภาพรวมระบบ

### หลักการหลัก: "GitOps for AI Personalization"

เราเปลี่ยนวิธีคิดจากการ "จัดการไฟล์" มาเป็นการ **"จัดการ Source Code ของสมอง AI"**

- **Brain (สมอง & พฤติกรรม):** เก็บใน **Git** (GitHub) เพื่อให้มี Version Control, Rollback ได้ และแก้ผ่าน IDE (VS Code) ได้อย่างปลอดภัย
    
- **Workspace (ผลงาน & ข้อมูลดิบ):** เก็บใน **Mutagen** เพื่อให้ซิงค์ไฟล์ขนาดใหญ่และทำงานร่วมกับ Obsidian บน Windows ได้แบบ Real-time
    
- **State (ฐานข้อมูล):** เก็บใน **Docker Volume** (Local) และ Backup ขึ้น Cloudflare R2 (Cold Storage)

### สถานะปัจจุบัน
- ✅ **Mutagen Sync** แทน Syncthing (เร็วจเร็วกกว่า)
- ✅ **GitOps Architecture** สำหรับ AI brain
- ✅ **Docker Compose** พร้อม host-mounted volumes
- ✅ **PowerShell 7 ARM64** สำหรับ Windows development
- ✅ **Official OpenClaw Image** (ลดความซับซ้อน)
- ✅ **AI Memory System** (ความจำระยะยาว)
- ✅ **Clean Documentation** (ทำความสะอาดและปรับปรุง)
- 🔄 **AI Processing** ทำงานทุกชั่วโมง (cron job)

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
│  │  OpenClaw 2GB      │  AI (Kimi) + Telegram            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ontoiq-vault/ (OpenClaw workspace = synced vault)          │
│  ├── 00-System/                        ← Templates & context
│  ├── 01-Raw-Content/                   ← n8n writes
│  ├── 02-Extracts/                      ← OpenClaw writes
│  ├── 03-Drafts/                        ← AI drafts, human reviews on Windows
│  └── skills/                           ← Per-agent skills
│  └── processed/      ← Original files after AI processing │
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

### OpenClaw - AI Runtime

| งาน | คำอธิบาย |
|------|-------------|
| **Real-time Chat** | การสนทนาผ่าน Telegram |
| **Content Creation** | สร้าง posts, articles, courses |
| **Content Analysis** | ดึงข้อมูลเชิงลึกจากเนื้อหาดิบ |
| **Vault Operations** | อ่าน/เขียนไฟล์ใน Obsidian vault |
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
| openclaw | build: ./openclaw | 2GB | 127.0.0.1:18789 | AI + Telegram |
| mutagen-sync | mutagen/mutagen:latest | 512MB | - | File Sync |

### Key Change: OpenClaw Volume

```yaml
openclaw:
  volumes:
    # Workspace = synced vault (unified)
    - ./brain:/home/openclaw/.openclaw
    - ./ontoiq-vault:/home/openclaw/.openclaw/workspace
```

---

## 6. โครงสร้าง Directory อย่างละเอียด

### Directory Structure บน Hostinger VPS

```
/root/ontoiq-system/                      <-- [GIT ROOT] Repository หลัก
├── .env                                  <-- Secrets (API Keys, Passwords)
├── .gitignore                            <-- Config ข้าม app-data/ และไฟล์ขยะ
├── docker-compose.yml                    <-- Orchestration หลัก
├── init.sql                              <-- Database initialization script
│
├── brain/                                <-- [GIT TRACKED] "สมองของ AI"
│   ├── AGENTS.md                         <-- AI agent personas
│   ├── TASKS.md                          <-- Standard Operating Procedures
│   ├── memory/                           <-- "ความจำระยะยาว" (Long-term Memory)
│   │   ├── 2026-02-16.md                 <-- AI daily logs
│   │   └── global_context.md             <-- Global AI context
│   └── skills/                           <-- Custom Python skills
│
├── ontoiq-vault/                         <-- [MUTAGEN SYNC] "พื้นที่ทำงาน"
│   ├── .openclaw/                        <-- Agent cache (exclude from Git)
│   ├── 00-System/                        <-- Templates และ System Context
│   ├── 01-Raw-Content/                   <-- n8n writes (YouTube/RSS)
│   ├── 02-Extracts/                      <-- OpenClaw writes (AI insights)
│   ├── 03-Drafts/                        <-- Human-AI collaboration
│   │   ├── processed/                      <-- Original files after AI
│   │   ├── blog-post-2026-02-16-enhanced.md
│   │   └── blog-post-2026-02-16-summary.md
│   ├── 04-Courseware/                    <-- Completed courses
│   ├── 06-Analytics/                     <-- n8n analytics reports
│   └── skills/                           <-- Per-agent skills
│
└── app-data/                             <-- [DOCKER VOLUMES] ฐานข้อมูล
    ├── postgres/                         <-- PostgreSQL data
    ├── qdrant/                           <-- Vector database
    ├── n8n/                              <-- Workflow configurations
    └── syncthing/                        <-- Legacy syncthing config
```

---

## 7. กลยุทธ์การ Sync ข้อมูล

### Sync Strategy Matrix

|**ประเภทข้อมูล**|**เก็บที่ไหน**|**เครื่องมือ**|**Workflow**|
|---|---|---|---|
|**1. Agent Persona & Logic**<br>(`AGENTS.md`, `TASKS.md`)|`brain/`|**Git (GitHub)**|1. แก้ใน VS Code<br>2. `git push`<br>3. VPS `git pull`<br>4. AI reloads|
|**2. AI Memory**<br>(`memory/*.md`)|`brain/memory/`|**Git (GitHub)**|1. AI writes on VPS<br>2. Cron job `git push`<br>3. Review on Windows|
|**3. Content & Drafts**<br>(`ontoiq-vault/`)|`ontoiq-vault/`|**Mutagen**|1. n8n/AI writes on VPS<br>2. Mutagen sync to Windows<br>3. Human edits in Obsidian<br>4. Sync back for publishing|
|**4. Database**<br>(Postgres/Qdrant)|`app-data/`|**Restic Backup**|1. Data in Docker volumes<br>2. Daily backup to Cloudflare R2|

---

## 8. การปรับใช้ Mutagen

### Mutagen Configuration

```bash
# Create sync session (Windows → VPS)
mutagen sync create --name=ontoiq-vault \
  ./ontoiq-vault \
  root@72.61.123.65:/root/ontoiq-system/ontoiq-vault \
  --mode=two-way-resolved \
  --ignore-vcs \
  --ignore=".DS_Store,Thumbs.db,*.tmp,*.log"
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

### Reliability Features
- **Automatic Backups**: Daily database backups to Cloudflare R2
- **Health Monitoring**: Comprehensive service health checks
- **Graceful Degradation**: System continues working with partial failures
- **Rollback Capability**: Git version control for AI brain

---

## 12. Implementation Status

### **✅ Completed**
- [x] Docker Compose configuration
- [x] Mutagen sync setup
- [x] GitOps architecture for AI brain
- [x] AI processing cron job
- [x] PowerShell scripts for Windows
- [x] Service health monitoring
- [x] Official OpenClaw Image migration
- [x] AI Memory system implementation
- [x] Documentation cleanup and consistency
- [x] File structure optimization

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

*Version: 3.0*  
*Updated: 2026-02-16*  
*Status: Implementation in Progress*
