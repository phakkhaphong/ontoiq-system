# Ontoiq Memory & RAG System

Complete Memory and RAG (Retrieval-Augmented Generation) system for Second Brain using PostgreSQL + Qdrant.

---

## Overview

**Goal**: Build an intelligent knowledge management system that serves as your "Second Brain" - capturing, organizing, and retrieving both academic knowledge and daily life experiences.

**Architecture**:
- **PostgreSQL**: Stores structured metadata, processing state, and full-text content
- **Qdrant**: Stores vector embeddings (1536 dimensions) for semantic search
- **n8n**: Orchestrates data pipelines
- **OpenClaw**: AI agent for content analysis and RAG responses

---

## Database Schema

### Tables

#### 1. knowledge_domains
Knowledge categories supporting both academic and daily life:
- **Academic**: Data Analytics, Microsoft Fabric, AI/ML, Data Engineering
- **Professional**: System Architecture, Project Management, Content Creation
- **Personal/Daily Life**: Daily Journal, Ideas, Meeting Notes, Reading List, Health

#### 2. content_sources
Raw content from various sources with infinite loop protection:
- `processing_state`: pending → processing → completed/failed
- `processing_attempts`: Count retries (max 3)
- Full-text search via `raw_content_fulltext` (TSVECTOR)

#### 3. content_chunks
Content split into embeddable chunks:
- Chunking strategies: paragraph, section, timestamp, slide
- Overlapping chunks to preserve context
- Links to Qdrant via `qdrant_point_id`

#### 4. content_lessons
Organized learning units with sequence ordering:
- Lesson numbers and sequence_order for curriculum
- Summary and key_takeaways for quick review
- Links to Qdrant for semantic retrieval

#### 5. knowledge_extracts
AI-extracted knowledge pieces:
- Types: concept, insight, quote, fact, procedure, definition, example
- Confidence and importance scoring
- Tags and entities for filtering
- Links to vault files in `02-Extracts/`

#### 6. processing_state_log
Infinite loop prevention and audit trail:
- Tracks every state transition
- Error logging with stack traces
- Agent/workflow attribution

#### 7. daily_memory_logs
Second Brain daily capture:
- Day summaries and key activities
- Energy/focus tracking (1-10 scale)
- Processing stats
- Links to vault files

#### 8. query_logs
RAG query analytics:
- Query text and embedding reference
- Results count and top results
- User feedback (helpful/not_helpful/irrelevant)
- Response time tracking

---

## n8n Workflows

### 1. Content Ingestion Pipeline
**File**: `n8n/workflows/content_ingestion.json`

**Trigger**: Every 6 hours
**Purpose**: Scan staging directory and ingest new content

**Flow**:
1. Scan `/vault/raw/{blogs,youtube,udemy,meeting,note}/`
2. Parse markdown frontmatter for metadata
3. Lookup domain_id from knowledge_domains
4. Insert into content_sources (ignore duplicates)
5. Chunk content into processable pieces
6. Insert into content_chunks
7. Trigger embedding pipeline

**Chunking Strategy**:
- Paragraph-based splitting
- Target: ~500 tokens per chunk
- 50-token overlap for context preservation

### 2. Embedding Pipeline
**File**: `n8n/workflows/embedding_pipeline.json`

**Trigger**: Every 15 minutes
**Purpose**: Generate embeddings for pending chunks

**Flow**:
1. Fetch chunks without qdrant_point_id (limit 10)
2. Batch chunks (size 5) with 2s rate limiting
3. Generate embeddings via OpenAI API
   - Model: `text-embedding-3-large`
   - Dimensions: 1536
4. Upsert to Qdrant collection `content_embeddings`
5. Update postgres with qdrant_point_id

**Rate Limiting**:
- 5 chunks per batch
- 2 second delay between batches
- Respects OpenAI API limits

### 3. AI Analysis Pipeline
**File**: `n8n/workflows/ai_analysis.json`

**Trigger**: Every 2 hours
**Purpose**: Process content with AI, extract knowledge

**Flow**:
1. Fetch pending content from `pending_content` view
2. Set state to `processing` via `transition_content_state()`
3. Call OpenClaw to analyze content
4. AI extracts concepts/insights/quotes
5. Save to `/output/` subdirectories
6. Set state to `completed` or `failed`

**Error Handling**:
- Max 3 retry attempts
- State logged for infinite loop prevention
- Telegram notification on failure

### 4. RAG Query Pipeline
**File**: `n8n/workflows/rag_query.json`

**Trigger**: Webhook endpoint `/webhook/rag-query`
**Purpose**: Answer user queries using semantic search

**Request Format**:
```json
{
  "query": "หา concept เรื่อง DAX",
  "domain": "data-analytics",
  "top_k": 5
}
```

**Flow**:
1. Parse query from webhook
2. Generate query embedding (OpenAI)
3. Search Qdrant (top_k results)
4. Fetch full chunk content from Postgres
5. Build context prompt
6. Call OpenClaw for AI response
7. Log query for analytics
8. Return response

---

## API Usage

### Query via Webhook
```bash
curl -X POST http://n8n:5678/webhook/rag-query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are the key DAX functions?",
    "top_k": 5
  }'
```

### Query via Telegram
Send message to bot: `/rag หา concept เรื่อง DAX`

---

## Monitoring

### Health Check Queries

```sql
-- System status
SELECT * FROM system_health;

-- Processing queue
SELECT * FROM pending_content;

-- Recent extracts
SELECT * FROM recent_extracts LIMIT 10;

-- Daily stats
SELECT * FROM daily_stats ORDER BY date DESC LIMIT 7;
```

### n8n Workflow Monitoring
- Check workflow execution logs in n8n UI
- Failed executions trigger Telegram notifications
- Query logs track RAG performance

---

## Setup Instructions

### 1. Database Initialization
```bash
# Schema is auto-applied via docker-compose volume
# postgres/init/01-schema.sql
# postgres/init/02-seed-data.sql

# Verify
docker exec ontoiq-postgres psql -U ontoiq -c "SELECT * FROM knowledge_domains;"
```

### 2. Qdrant Collection Setup
```bash
# Create collection
curl -X PUT http://localhost:6333/collections/content_embeddings \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": {
      "size": 1536,
      "distance": "Cosine"
    }
  }'
```

### 3. Import n8n Workflows
1. Open n8n UI: https://n8n.ontoiq.tech/
2. Import workflows from `n8n/workflows/`
3. Configure credentials:
   - PostgreSQL: `postgres-ontoiq`
   - OpenAI: `openai-api`
   - Telegram: `telegram-bot`
4. Activate workflows

### 4. OpenClaw Integration
Add to `openclaw-workspace/AGENTS.md`:
```markdown
## Database & RAG Tools

### query_postgres
Query PostgreSQL for structured data
```

---

## Cost Estimation (Monthly)

| Component | Volume | Cost |
|-----------|--------|------|
| OpenAI Embeddings | 10K requests | ~$1.30 |
| OpenAI Chat (RAG) | 1K queries | ~$5.00 |
| Postgres Storage | 5GB | $0 (local) |
| Qdrant Storage | 6GB | $0 (local) |
| **Total** | | **~$6.30/month** |

---

## Success Criteria

✅ **Database**: All tables created with proper indexes and relationships  
✅ **State Management**: No infinite loops, failed items retried ≤ 3 times  
✅ **RAG Performance**: Query response < 10 seconds with relevant results  
✅ **Second Brain**: Daily captures stored and searchable  
✅ **Full-text Search**: Can find exact phrases in raw content  
✅ **Semantic Search**: Can find related concepts by meaning (Qdrant)  
✅ **Integration**: n8n workflows run automatically without manual intervention  

---

*System Version: 1.0*  
*Last Updated: 2026-02-17*  
*Status: Implementation Complete*
