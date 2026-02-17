-- ==========================================
-- Ontoiq Memory & RAG System - Seed Data
-- Version: 1.0
-- Purpose: Default knowledge domains for Second Brain
-- ==========================================

-- Insert default knowledge domains for academic and daily life use cases
INSERT INTO knowledge_domains (name, slug, description, domain_type, priority, color_code, icon, metadata) VALUES
-- Academic Domains
('Data Analytics', 'data-analytics', 'Power BI, DAX, SQL, and data visualization techniques', 'academic', 10, '#3b82f6', 'chart-bar', '{"skills": ["power-bi", "dax", "sql", "visualization"]}'),
('Microsoft Fabric', 'microsoft-fabric', 'OneLake, Data Factory, Data Science, and Real-time Analytics', 'academic', 9, '#00a4ef', 'cloud', '{"skills": ["onelake", "data-factory", "data-science"]}'),
('AI & Machine Learning', 'ai-machine-learning', 'Agentic AI, LLMs, embeddings, and RAG systems', 'academic', 8, '#8b5cf6', 'brain', '{"skills": ["llm", "embeddings", "rag", "agents"]}'),
('Data Engineering', 'data-engineering', 'ETL pipelines, data lakes, and data architecture', 'academic', 7, '#10b981', 'database', '{"skills": ["etl", "data-lake", "spark"]}'),

-- Professional Domains
('System Architecture', 'system-architecture', 'System design, DevOps, and infrastructure planning', 'professional', 6, '#f59e0b', 'server', '{"skills": ["docker", "kubernetes", "ci-cd"]}'),
('Project Management', 'project-management', 'Agile methodologies, task tracking, and team coordination', 'professional', 5, '#ec4899', 'clipboard-list', '{"skills": ["agile", "scrum", "kanban"]}'),
('Content Creation', 'content-creation', 'Blog writing, video scripts, and social media content', 'professional', 4, '#ef4444', 'video', '{"skills": ["writing", "scripting", "editing"]}'),

-- Daily Life Domains (Second Brain)
('Daily Journal', 'daily-journal', 'Daily reflections, thoughts, and personal notes', 'daily_life', 10, '#6366f1', 'book-open', '{"type": "capture", "auto_process": true}'),
('Ideas & Inspiration', 'ideas-inspiration', 'Random ideas, creative sparks, and inspiration', 'daily_life', 9, '#f97316', 'lightbulb', '{"type": "capture", "auto_process": false}'),
('Meeting Notes', 'meeting-notes', 'Meeting summaries, action items, and decisions', 'daily_life', 8, '#14b8a6', 'users', '{"type": "structured", "auto_extract": true}'),
('Reading List', 'reading-list', 'Books, articles, and resources to read or have read', 'daily_life', 7, '#84cc16', 'bookmark', '{"type": "reference", "track_completion": true}'),
('Health & Wellness', 'health-wellness', 'Health tracking, habits, and wellness notes', 'personal', 6, '#22c55e', 'heart', '{"type": "tracking", "metrics": ["energy", "focus", "mood"]}'),
('Finance & Budget', 'finance-budget', 'Financial tracking, investments, and budgeting', 'personal', 5, '#eab308', 'currency-dollar', '{"type": "tracking", "sensitive": true}'),
('Travel & Places', 'travel-places', 'Travel plans, visited places, and recommendations', 'personal', 4, '#06b6d4', 'map-pin', '{"type": "reference", "geo_tagged": true}'),
('Family & Friends', 'family-friends', 'Important dates, contacts, and social connections', 'personal', 3, '#f43f5e', 'heart-handshake', '{"type": "reference", "reminders": true}');

-- Insert sample content source for testing
INSERT INTO content_sources (
    source_type, 
    title, 
    url, 
    author, 
    source_platform,
    duration_seconds,
    raw_content,
    processing_state,
    domain_id
) 
SELECT 
    'youtube',
    'Power BI DAX Tutorial for Beginners',
    'https://youtube.com/watch?v=sample123',
    'SQLBI',
    'YouTube',
    1800,
    'This is a sample content for testing the RAG system. In this tutorial, we cover the basics of DAX including CALCULATE, FILTER, and SUMX functions. DAX is a powerful formula language for Power BI that allows you to create custom calculations and measures.',
    'pending',
    id
FROM knowledge_domains 
WHERE slug = 'data-analytics';

-- Insert sample knowledge extract for testing
INSERT INTO knowledge_extracts (
    source_id,
    extract_type,
    title,
    content,
    tags,
    confidence_score,
    vault_file_path
)
SELECT 
    cs.id,
    'concept',
    'DAX (Data Analysis Expressions)',
    'DAX is a formula language used in Power BI, Excel Power Pivot, and SSAS. It is designed to work with relational data and perform advanced calculations on data models.',
    ARRAY['dax', 'power-bi', 'formula-language'],
    0.92,
    '/output/concepts/dax-introduction-2026-02-17.md'
FROM content_sources cs
WHERE cs.title = 'Power BI DAX Tutorial for Beginners';

-- ==========================================
-- COMPLETION
-- ==========================================
DO $$
DECLARE
    domain_count INTEGER;
    source_count INTEGER;
    extract_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO domain_count FROM knowledge_domains;
    SELECT COUNT(*) INTO source_count FROM content_sources;
    SELECT COUNT(*) INTO extract_count FROM knowledge_extracts;
    
    RAISE NOTICE 'Seed data inserted successfully:';
    RAISE NOTICE '  - % knowledge domains', domain_count;
    RAISE NOTICE '  - % content sources', source_count;
    RAISE NOTICE '  - % knowledge extracts', extract_count;
END $$;
