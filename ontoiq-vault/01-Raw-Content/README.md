# Staging Directory

**Purpose**: Raw content from external sources (READ-ONLY)

**Location**: `/staging/` → symlinks to `../ontoiq-vault/01-Raw-Content/`

---

## Structure

### blogs/
Blog articles scraped from various sources
- Example: `blogs/techcrunch-ai-trends.md`
- Content: Full article text, metadata

### youtube/
YouTube video transcripts and metadata
- Example: `youtube/powerbi-dax-tutorial.md`
- Content: Video transcript, title, description, channel

### udemy/
Udemy course information and outlines
- Example: `udemy/fabric-analytics-course.md`
- Content: Course description, curriculum, instructor info

---

## Usage

### For AI Agents
1. **Read** files from appropriate subdirectory
2. **Process** content (extract, analyze, summarize)
3. **Write** results to `/output/` (not here!)

### Example Workflow
```
Read: /staging/blogs/ai-article.md
Process: Extract key concepts
Write: /output/concepts/ai-concepts-2026-02-17.md
```

---

## Important Rules

⚠️ **READ-ONLY** - Do NOT write to this directory
⚠️ Content here is managed by n8n and external sources
⚠️ Process and save results to `/output/`

---

## See Also
- TOOLS.md - Directory Structure Reference
- AGENTS.md - Directory Awareness section
- /output/README.md - Where to write results
