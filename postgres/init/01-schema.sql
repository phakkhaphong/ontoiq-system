-- ==========================================
-- Ontoiq Memory & RAG System Schema
-- Version: 1.0
-- Purpose: Structured storage for Second Brain
-- ==========================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For full-text search

-- ==========================================
-- 1. KNOWLEDGE DOMAINS (หัวข้อวิชา/หมวดหมู่ชีวิต)
-- ==========================================
CREATE TABLE knowledge_domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    domain_type VARCHAR(50) NOT NULL CHECK (domain_type IN ('academic', 'professional', 'personal', 'daily_life')),
    parent_id UUID REFERENCES knowledge_domains(id) ON DELETE SET NULL,
    priority INTEGER DEFAULT 0,
    color_code VARCHAR(7) DEFAULT '#3b82f6',
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_domains_slug ON knowledge_domains(slug);
CREATE INDEX idx_domains_type ON knowledge_domains(domain_type);
CREATE INDEX idx_domains_parent ON knowledge_domains(parent_id);

-- ==========================================
-- 2. CONTENT SOURCES (แหล่งข้อมูลดิบ)
-- ==========================================
CREATE TABLE content_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('youtube', 'blog', 'article', 'pdf', 'book', 'podcast', 'meeting', 'note', 'message')),
    title VARCHAR(500) NOT NULL,
    url VARCHAR(1000),
    author VARCHAR(255),
    source_platform VARCHAR(100),
    
    -- Media metadata
    duration_seconds INTEGER,
    file_size_bytes BIGINT,
    content_format VARCHAR(50),
    language VARCHAR(10) DEFAULT 'th',
    
    -- Content storage
    raw_content TEXT,
    raw_content_fulltext TSVECTOR,  -- For full-text search
    
    -- Processing state (Infinite Loop Prevention)
    processing_state VARCHAR(50) DEFAULT 'pending' 
        CHECK (processing_state IN ('pending', 'processing', 'completed', 'failed', 'retrying')),
    processing_attempts INTEGER DEFAULT 0,
    last_processed_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    
    -- Relationships
    domain_id UUID REFERENCES knowledge_domains(id) ON DELETE SET NULL,
    
    -- Timestamps
    source_published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Unique constraint for deduplication
    UNIQUE(source_type, url)
);

-- Indexes for performance
CREATE INDEX idx_sources_state ON content_sources(processing_state);
CREATE INDEX idx_sources_type ON content_sources(source_type);
CREATE INDEX idx_sources_domain ON content_sources(domain_id);
CREATE INDEX idx_sources_created ON content_sources(created_at DESC);
CREATE INDEX idx_sources_fulltext ON content_sources USING GIN(raw_content_fulltext);

-- Trigger for full-text search
CREATE OR REPLACE FUNCTION update_fulltext_search()
RETURNS TRIGGER AS $$
BEGIN
    NEW.raw_content_fulltext := to_tsvector('simple', COALESCE(NEW.raw_content, ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_fulltext
    BEFORE INSERT OR UPDATE ON content_sources
    FOR EACH ROW
    EXECUTE FUNCTION update_fulltext_search();

-- ==========================================
-- 3. CONTENT CHUNKS (สำหรับ Embedding)
-- ==========================================
CREATE TABLE content_chunks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID REFERENCES content_sources(id) ON DELETE CASCADE,
    chunk_number INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    chunk_text_fulltext TSVECTOR,
    chunk_type VARCHAR(50) CHECK (chunk_type IN ('paragraph', 'section', 'timestamp', 'slide')),
    start_position INTEGER,
    end_position INTEGER,
    qdrant_point_id UUID,
    embedding_model VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_chunks_source ON content_chunks(source_id);
CREATE INDEX idx_chunks_number ON content_chunks(chunk_number);
CREATE INDEX idx_chunks_fulltext ON content_chunks USING GIN(chunk_text_fulltext);

-- Trigger for chunk full-text search
CREATE TRIGGER trigger_update_chunk_fulltext
    BEFORE INSERT OR UPDATE ON content_chunks
    FOR EACH ROW
    EXECUTE FUNCTION update_fulltext_search();

-- ==========================================
-- 4. LESSONS / CONTENT UNITS (บทเรียน/หน่วยความรู้)
-- ==========================================
CREATE TABLE content_lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID REFERENCES content_sources(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES knowledge_domains(id) ON DELETE SET NULL,
    
    -- Lesson metadata
    title VARCHAR(500) NOT NULL,
    lesson_number INTEGER,
    sequence_order INTEGER DEFAULT 0,
    
    -- Content summary (for quick browsing)
    summary TEXT,
    key_takeaways TEXT[],
    
    -- Processing state (Infinite Loop Prevention)
    analysis_state VARCHAR(50) DEFAULT 'pending'
        CHECK (analysis_state IN ('pending', 'processing', 'completed', 'failed', 'retrying')),
    analysis_attempts INTEGER DEFAULT 0,
    last_analyzed_at TIMESTAMP WITH TIME ZONE,
    
    -- Vector reference (links to Qdrant)
    qdrant_point_id UUID,
    embedding_model VARCHAR(100),
    
    -- Quality metrics
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    relevance_score DECIMAL(3,2) CHECK (relevance_score >= 0 AND relevance_score <= 1),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_lessons_source ON content_lessons(source_id);
CREATE INDEX idx_lessons_domain ON content_lessons(domain_id);
CREATE INDEX idx_lessons_state ON content_lessons(analysis_state);
CREATE INDEX idx_lessons_sequence ON content_lessons(sequence_order);

-- ==========================================
-- 5. KNOWLEDGE EXTRACTS (AI Extracted Knowledge)
-- ==========================================
CREATE TABLE knowledge_extracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES content_lessons(id) ON DELETE CASCADE,
    source_id UUID REFERENCES content_sources(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES knowledge_domains(id) ON DELETE SET NULL,
    
    -- Extract type
    extract_type VARCHAR(50) NOT NULL 
        CHECK (extract_type IN ('concept', 'insight', 'quote', 'fact', 'procedure', 'definition', 'example')),
    
    -- Content
    title VARCHAR(500),
    content TEXT NOT NULL,
    content_fulltext TSVECTOR,
    
    -- Context
    context_before TEXT,
    context_after TEXT,
    timestamp_reference VARCHAR(50),  -- For video: "05:32"
    
    -- Tags & categorization
    tags TEXT[],
    entities TEXT[],
    
    -- Quality metrics
    confidence_score DECIMAL(3,2) DEFAULT 0.85,
    importance_score DECIMAL(3,2) DEFAULT 0.5,
    
    -- Vector reference
    qdrant_point_id UUID,
    
    -- File reference (links to vault)
    vault_file_path VARCHAR(500),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_extracts_lesson ON knowledge_extracts(lesson_id);
CREATE INDEX idx_extracts_type ON knowledge_extracts(extract_type);
CREATE INDEX idx_extracts_domain ON knowledge_extracts(domain_id);
CREATE INDEX idx_extracts_fulltext ON knowledge_extracts USING GIN(content_fulltext);
CREATE INDEX idx_extracts_tags ON knowledge_extracts USING GIN(tags);

-- Trigger for full-text search
CREATE TRIGGER trigger_update_extract_fulltext
    BEFORE INSERT OR UPDATE ON knowledge_extracts
    FOR EACH ROW
    EXECUTE FUNCTION update_fulltext_search();

-- ==========================================
-- 6. PROCESSING STATE LOG (Infinite Loop Prevention)
-- ==========================================
CREATE TABLE processing_state_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('content_source', 'content_chunk', 'lesson', 'extract', 'workflow')),
    entity_id UUID NOT NULL,
    
    -- State tracking
    previous_state VARCHAR(50),
    new_state VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    
    -- Error tracking
    error_code VARCHAR(100),
    error_message TEXT,
    stack_trace TEXT,
    
    -- Agent/workflow info
    agent_id VARCHAR(100),
    workflow_id VARCHAR(100),
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_state_log_entity ON processing_state_log(entity_type, entity_id);
CREATE INDEX idx_state_log_created ON processing_state_log(created_at DESC);

-- ==========================================
-- 7. DAILY MEMORY LOGS (Second Brain Daily Capture)
-- ==========================================
CREATE TABLE daily_memory_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    log_date DATE NOT NULL UNIQUE,
    
    -- Summary
    day_summary TEXT,
    key_activities TEXT[],
    insights_generated INTEGER DEFAULT 0,
    
    -- Processing stats
    sources_processed INTEGER DEFAULT 0,
    lessons_created INTEGER DEFAULT 0,
    extracts_generated INTEGER DEFAULT 0,
    
    -- Mood/energy (for personal tracking)
    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    focus_level INTEGER CHECK (focus_level >= 1 AND focus_level <= 10),
    
    -- Linked vault file
    vault_file_path VARCHAR(500),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_memory_logs_date ON daily_memory_logs(log_date);

-- ==========================================
-- 8. QUERY LOGS (For RAG Improvement)
-- ==========================================
CREATE TABLE query_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    query_text TEXT NOT NULL,
    query_vector_id UUID,  -- Reference to Qdrant query embedding
    
    -- Results
    results_count INTEGER,
    top_result_ids UUID[],
    
    -- Feedback
    user_feedback VARCHAR(20) CHECK (user_feedback IN ('helpful', 'not_helpful', 'irrelevant')),
    
    -- Performance
    response_time_ms INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_query_logs_created ON query_logs(created_at DESC);

-- ==========================================
-- VIEWS FOR COMMON QUERIES
-- ==========================================

-- View: Pending Content (for processing queue)
CREATE VIEW pending_content AS
SELECT 
    cs.id,
    cs.title,
    cs.source_type,
    cs.url,
    cs.processing_state,
    cs.processing_attempts,
    cs.created_at,
    kd.name as domain_name
FROM content_sources cs
LEFT JOIN knowledge_domains kd ON cs.domain_id = kd.id
WHERE cs.processing_state IN ('pending', 'failed', 'retrying')
    AND cs.processing_attempts < 3
ORDER BY cs.created_at ASC;

-- View: Recent Extracts with Context
CREATE VIEW recent_extracts AS
SELECT 
    ke.id,
    ke.title,
    ke.extract_type,
    ke.content,
    ke.tags,
    ke.confidence_score,
    cs.title as source_title,
    cs.source_type,
    kd.name as domain_name,
    ke.created_at
FROM knowledge_extracts ke
JOIN content_sources cs ON ke.source_id = cs.id
LEFT JOIN knowledge_domains kd ON ke.domain_id = kd.id
ORDER BY ke.created_at DESC;

-- View: Processing Dashboard
CREATE VIEW processing_dashboard AS
SELECT 
    processing_state,
    COUNT(*) as count,
    AVG(processing_attempts) as avg_attempts,
    MAX(last_processed_at) as last_activity
FROM content_sources
GROUP BY processing_state;

-- View: Daily Stats
CREATE VIEW daily_stats AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as sources_added,
    SUM(CASE WHEN processing_state = 'completed' THEN 1 ELSE 0 END) as completed
FROM content_sources
GROUP BY DATE(created_at);

-- View: System Health
CREATE VIEW system_health AS
SELECT 
    (SELECT COUNT(*) FROM content_sources WHERE processing_state = 'pending') as pending_items,
    (SELECT COUNT(*) FROM content_sources WHERE processing_state = 'failed' AND processing_attempts >= 3) as permanently_failed,
    (SELECT COUNT(*) FROM content_chunks WHERE qdrant_point_id IS NULL) as missing_embeddings,
    (SELECT COUNT(*) FROM daily_memory_logs WHERE log_date = CURRENT_DATE) as today_memories,
    (SELECT AVG(response_time_ms) FROM query_logs WHERE created_at > NOW() - INTERVAL '1 hour') as avg_query_time_ms;

-- ==========================================
-- FUNCTIONS FOR STATE MANAGEMENT
-- ==========================================

-- Function: Safe state transition (prevents invalid transitions)
CREATE OR REPLACE FUNCTION transition_content_state(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_new_state VARCHAR,
    p_action VARCHAR,
    p_error_message TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_current_state VARCHAR;
BEGIN
    -- Get current state based on entity type
    CASE p_entity_type
        WHEN 'content_source' THEN
            SELECT processing_state INTO v_current_state FROM content_sources WHERE id = p_entity_id;
            UPDATE content_sources SET 
                processing_state = p_new_state,
                processing_attempts = CASE WHEN p_new_state = 'processing' THEN processing_attempts + 1 ELSE processing_attempts END,
                last_processed_at = CASE WHEN p_new_state IN ('completed', 'failed') THEN NOW() ELSE last_processed_at END,
                error_message = p_error_message,
                updated_at = NOW()
            WHERE id = p_entity_id;
        WHEN 'content_chunk' THEN
            -- Chunks don't have state, skip
            NULL;
        WHEN 'lesson' THEN
            SELECT analysis_state INTO v_current_state FROM content_lessons WHERE id = p_entity_id;
            UPDATE content_lessons SET 
                analysis_state = p_new_state,
                analysis_attempts = CASE WHEN p_new_state = 'processing' THEN analysis_attempts + 1 ELSE analysis_attempts END,
                last_analyzed_at = CASE WHEN p_new_state IN ('completed', 'failed') THEN NOW() ELSE last_analyzed_at END,
                updated_at = NOW()
            WHERE id = p_entity_id;
    END CASE;
    
    -- Log the state transition
    INSERT INTO processing_state_log (
        entity_type, entity_id, previous_state, new_state, 
        action, error_message
    ) VALUES (
        p_entity_type, p_entity_id, v_current_state, p_new_state,
        p_action, p_error_message
    );
END;
$$ LANGUAGE plpgsql;

-- Function: Search extracts by full-text
CREATE OR REPLACE FUNCTION search_extracts(p_query TEXT)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    content TEXT,
    extract_type VARCHAR,
    confidence_score DECIMAL,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ke.id,
        ke.title,
        ke.content,
        ke.extract_type,
        ke.confidence_score,
        ts_rank(ke.content_fulltext, plainto_tsquery('simple', p_query)) as rank
    FROM knowledge_extracts ke
    WHERE ke.content_fulltext @@ plainto_tsquery('simple', p_query)
    ORDER BY rank DESC, ke.confidence_score DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- Function: Search content sources by full-text
CREATE OR REPLACE FUNCTION search_sources(p_query TEXT)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    source_type VARCHAR,
    url VARCHAR,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cs.id,
        cs.title,
        cs.source_type,
        cs.url,
        ts_rank(cs.raw_content_fulltext, plainto_tsquery('simple', p_query)) as rank
    FROM content_sources cs
    WHERE cs.raw_content_fulltext @@ plainto_tsquery('simple', p_query)
    ORDER BY rank DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- Function: Log daily memory
CREATE OR REPLACE FUNCTION log_daily_memory(
    p_log_date DATE,
    p_day_summary TEXT,
    p_key_activities TEXT[],
    p_energy_level INTEGER DEFAULT NULL,
    p_focus_level INTEGER DEFAULT NULL,
    p_vault_file_path VARCHAR DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO daily_memory_logs (
        log_date, day_summary, key_activities, 
        energy_level, focus_level, vault_file_path
    ) VALUES (
        p_log_date, p_day_summary, p_key_activities,
        p_energy_level, p_focus_level, p_vault_file_path
    )
    ON CONFLICT (log_date) 
    DO UPDATE SET 
        day_summary = p_day_summary,
        key_activities = p_key_activities,
        energy_level = COALESCE(p_energy_level, daily_memory_logs.energy_level),
        focus_level = COALESCE(p_focus_level, daily_memory_logs.focus_level),
        vault_file_path = COALESCE(p_vault_file_path, daily_memory_logs.vault_file_path),
        updated_at = NOW()
    RETURNING id INTO v_id;
    
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- COMPLETION
-- ==========================================
DO $$
BEGIN
    RAISE NOTICE 'Ontoiq Memory & RAG Schema v1.0 created successfully';
    RAISE NOTICE 'Tables created: knowledge_domains, content_sources, content_chunks, content_lessons, knowledge_extracts, processing_state_log, daily_memory_logs, query_logs';
    RAISE NOTICE 'Views created: pending_content, recent_extracts, processing_dashboard, daily_stats, system_health';
    RAISE NOTICE 'Functions created: transition_content_state, search_extracts, search_sources, log_daily_memory';
END $$;
