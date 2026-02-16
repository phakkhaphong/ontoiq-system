# Ontoiq System

AI-powered content management system with OpenClaw, n8n, and Obsidian integration.

## Repository Structure

```
/opt/ontoiq-system/                      <-- [GIT ROOT] Repository
│
├── .env                                  <-- Environment variables (secrets, not in Git)
├── .env.example                          <-- Template for .env
├── .gitignore                            <-- Git ignore rules
├── docker-compose.yml                    <-- Docker orchestration
├── README.md                             <-- This file
│
├── backups/                              <-- [DATA] Backup storage (gitignored)
│
├── docs/                                 <-- [DOCS] Documentation
│   └── ontoiq-master-plan-v3.md          ← System architecture docs
│
├── n8n/                                  <-- [DATA] Docker volume (gitignored)
│   └── data/                             ← n8n workflows & credentials
│
├── ontoiq-vault/                         <-- [GIT] Obsidian Vault (synced via Mutagen)
│   ├── 00-System/                        ← Obsidian templates & guides
│   ├── 01-Raw-Content/                   ← n8n writes (YouTube, RSS, etc.)
│   ├── 02-Extracts/                      ← OpenClaw writes (AI insights)
│   ├── 03-Drafts/                        ← Human-AI collaboration
│   ├── 04-Published/                     ← Final content
│   ├── 05-Templates/                     ← Content templates
│   ├── 06-Analytics/                     ← n8n analytics reports
│   ├── .gitignore                        ← Vault-specific ignores
│   └── README.md                         ← Vault documentation
│
├── openclaw-workspace/                   <-- [GIT] OpenClaw Config (tracked as source code)
│   ├── AGENTS.md                         ← OpenClaw: Operating instructions
│   ├── SOUL.md                           ← OpenClaw: Persona & tone
│   ├── USER.md                           ← OpenClaw: User context
│   ├── IDENTITY.md                       ← OpenClaw: Agent identity
│   ├── TOOLS.md                          ← OpenClaw: Local tools
│   ├── BOOTSTRAP.md                      ← OpenClaw: Startup checklist
│   ├── HEARTBEAT.md                      ← OpenClaw: Heartbeat checklist
│   ├── memory/                           ← Daily logs (gitignored)
│   ├── skills/                           ← Custom skills
│   ├── staging →                         ← Symlink to ontoiq-vault/01-Raw-Content/
│   └── output →                          ← Symlink to ontoiq-vault/02-Extracts/
│
├── postgres/                             <-- [DATA] Docker volume (gitignored)
│   ├── data/                             ← PostgreSQL database
│   └── init/                             ← Init scripts
│
├── qdrant/                               <-- [DATA] Docker volume (gitignored)
│   ├── storage/                          ← Vector database
│   └── snapshots/                        ← Qdrant backups
│
└── scripts/                              <-- [GIT] Utility scripts
    └── setup-disaster-recovery.sh        ← VPS recovery script
```

## Legend

- **[GIT]** - Tracked in Git repository (source code)
- **[DATA]** - Docker volumes, runtime data (gitignored, backup separately)
- **[DOCS]** - Documentation

## Quick Start

### Fresh VPS Setup

```bash
# Clone repository
git clone https://github.com/phakkhaphong/ontoiq-system.git /opt/ontoiq-system
cd /opt/ontoiq-system

# Run setup script
sudo ./scripts/setup-disaster-recovery.sh

# Edit environment variables
nano /opt/ontoiq-system/.env

# Start services
docker compose --env-file .env up -d
```

### Windows Sync (Mutagen)

```bash
# On Windows (with Mutagen installed)
mutagen sync create \
  ./ontoiq-vault \
  root@vps:/opt/ontoiq-system/ontoiq-vault \
  --name=ontoiq-vault
```

## Services

| Service | Type | Port | Description |
|---------|------|------|-------------|
| PostgreSQL | Docker | 127.0.0.1:5432 | Content database |
| Qdrant | Docker | 127.0.0.1:6333 | Vector search |
| n8n | Docker | 127.0.0.1:5678 | Workflow automation |
| OpenClaw | Bare Metal | Gateway | AI agent |

## Disaster Recovery

### What to Backup

1. **Git Repository** - Contains all source code and configs
2. **Docker Volumes** - n8n/data/, postgres/data/, qdrant/storage/
3. **Environment** - .env (store securely, not in Git)
4. **Obsidian Vault** - ontoiq-vault/ (synced via Mutagen)

### Recovery Steps

1. Clone repository: `git clone https://github.com/phakkhaphong/ontoiq-system.git`
2. Run setup: `sudo ./scripts/setup-disaster-recovery.sh`
3. Restore .env from secure backup
4. Restore Docker volumes from backup
5. Start services: `docker compose --env-file .env up -d`

## Architecture

- **n8n** (Docker) → Ingests content → writes to `ontoiq-vault/01-Raw-Content/`
- **OpenClaw** (Bare Metal) → Reads from `staging/` → Processes → Writes to `output/`
- **Obsidian** (Windows) → Syncs via Mutagen → Human edits in `03-Drafts/`

See `docs/ontoiq-master-plan-v3.md` for detailed architecture.

## Security

- `.env` contains secrets - **never commit to Git**
- Use `.env.example` as template
- OpenClaw workspace separated from vault to prevent infinite loops
- ACL permissions set for n8n container access
