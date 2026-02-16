# Ontoiq Tools Reference

## Available Tools

### File Operations

#### read
Read file contents from vault.
```
read(path: string) → string
```
- Path is relative to workspace root
- Returns file contents or error

#### write
Create or overwrite a file.
```
write(path: string, content: string) → void
```
- Creates directories if needed
- Overwrites existing files

#### edit
Edit specific parts of a file.
```
edit(path: string, oldString: string, newString: string) → void
```
- Must match oldString exactly
- Fails if not found

### Knowledge Operations

#### search_files
Search vault for files matching pattern.
```
search_files(pattern: string) → string[]
```
- Uses glob patterns
- Returns file paths

#### search_content
Search file contents for text.
```
search_content(regex: string) → matches[]
```
- Uses regex patterns
- Returns file + line numbers

### Database Operations

#### query_postgres
Execute SQL query.
```
query_postgres(sql: string) → rows[]
```
- Read-only by default
- Tables: content_sources, knowledge_extracts, content_outputs

#### query_qdrant
Search vector database.
```
query_qdrant(query: string, limit: number) → results[]
```
- Semantic search
- Returns similar content

### Communication

#### send_telegram
Send message to user via Telegram.
```
send_telegram(message: string) → void
```

#### trigger_n8n
Trigger n8n workflow.
```
trigger_n8n(workflow: string, data: object) → void
```
- Available workflows:
  - `create-post`
  - `youtube-summary`
  - `publish-scheduled`

## n8n Integration

### Webhook Endpoints

| Endpoint | Trigger | Purpose |
|----------|---------|---------|
| `/webhook/ontoiq/create-post` | OpenClaw | Create social post |
| `/webhook/ontoiq/youtube-summary` | OpenClaw | Summarize video |
| `/webhook/ontoiq/publish` | OpenClaw | Publish ready content |
| `/webhook/ontoiq/notify` | n8n → OpenClaw | Send notification |

### Calling n8n from OpenClaw

```javascript
// Trigger workflow
fetch('http://n8n:5678/webhook/ontoiq/create-post', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Webhook-Secret': process.env.N8N_WEBHOOK_SECRET
  },
  body: JSON.stringify({
    topic: 'Power BI DAX',
    platform: 'linkedin',
    userId: process.env.USER_TELEGRAM_ID
  })
});
```

### Receiving from n8n

n8n sends to OpenClaw via:
```javascript
fetch('http://openclaw:18789/tools/invoke', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${GATEWAY_TOKEN}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    tool: 'sessions_send',
    args: {
      sessionKey: 'agent:main:main',
      message: '📥 มี content ใหม่ 5 รายการ'
    }
  })
});
```

## Database Schema

### content_sources
```sql
SELECT * FROM content_sources 
WHERE status = 'pending' 
ORDER BY created_at DESC;
```

### knowledge_extracts
```sql
SELECT * FROM knowledge_extracts 
WHERE 'agentic-ai' = ANY(tags)
ORDER BY confidence DESC;
```

### content_outputs
```sql
SELECT * FROM content_outputs 
WHERE status = 'draft' 
  AND platform = 'twitter'
ORDER BY created_at DESC;
```

## Vault Conventions

### File Naming
- Lowercase with hyphens: `power-bi-dax-basics.md`
- Date prefix for daily files: `2026-02-13.md`
- Category prefix: `insight-fabric-lakehouse.md`

### Frontmatter
```yaml
---
title: Power BI DAX Basics
tags: [power-bi, dax, data-analysis]
created: 2026-02-13
status: draft
source: youtube.com/xxx
confidence: 0.85
---
```

### Tags
Use consistent tags:
- Topics: `power-bi`, `fabric`, `agentic-ai`, `ml`
- Types: `insight`, `concept`, `quote`, `tutorial`
- Status: `draft`, `ready`, `published`

## Error Handling

### File Not Found
```
Error: File not found: 02-Extracts/nonexistent.md
Action: Check path, suggest alternatives
```

### Database Error
```
Error: Connection refused to postgres:5432
Action: Retry with backoff, notify user
```

### n8n Timeout
```
Error: Webhook timeout after 30s
Action: Log error, notify user, retry later
```

## Rate Limits

| Resource | Limit |
|----------|-------|
| File reads | Unlimited |
| File writes | 100/minute |
| API calls | 60/minute |
| Embedding queries | 30/minute |

## Security

### Allowed Operations
- Read any file in vault
- Write to 02-Extracts/, 03-Drafts/, 04-Courseware/
- Query database (read-only)
- Send Telegram messages

### Restricted Operations
- Delete files (requires confirmation)
- Modify 00-System/, 05-Published/
- Access outside vault
- Execute shell commands (sandboxed)

---

*Reference for tool usage in Ontoiq system*
