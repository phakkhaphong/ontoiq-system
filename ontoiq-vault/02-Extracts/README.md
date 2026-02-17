# Output Directory

**Purpose**: AI-generated content and extracts (WRITE-ONLY)

**Location**: `/output/` → symlinks to `../ontoiq-vault/02-Extracts/`

---

## Structure

### concepts/
Key concept extractions and definitions
- Example: `concept-ai-agents-2026-02-17.md`
- Content: Technical terms, definitions, key concepts

### insights/
Content analysis and insights
- Example: `insight-powerbi-trends-2026-02-17.md`
- Content: Summaries, trend analysis, key takeaways

### quotes/
Notable quotes extracted from sources
- Example: `quotes-expert-opinions-2026-02-17.md`
- Content: Important statements, expert opinions

### (root)
General extracts and summaries
- Example: `nvidia-wikipedia-2026-02-17.md`
- Content: Full article extracts, comprehensive summaries

---

## Naming Convention

**Format**: `{topic}-{YYYY-MM-DD}.md`

**Examples**:
- `concept-machine-learning-2026-02-17.md`
- `insight-data-trends-2026-02-17.md`
- `ai-ethics-summary-2026-02-17.md`

---

## Usage

### For AI Agents
1. **Read** from `/staging/` (source content)
2. **Process** with AI (extract, analyze, summarize)
3. **Write** to appropriate subdirectory here
4. **Notify** user via Telegram

### Example Workflow
```
Read: /staging/blogs/ai-article.md
Process: Extract key concepts
Write: /output/concepts/ai-concepts-2026-02-17.md
Notify: Telegram with summary and file link
```

---

## Important Rules

⚠️ **WRITE-ONLY** - This is for AI output only
⚠️ You may read your own outputs for reference
⚠️ Choose correct subdirectory by content type
⚠️ Use naming convention consistently
⚠️ Check for duplicates before writing

---

## Content Type Guide

| Source Content | Output Type | Directory |
|----------------|-------------|-----------|
| Blog article → | Concepts | `/output/concepts/` |
| Video transcript → | Insights | `/output/insights/` |
| Interview → | Quotes | `/output/quotes/` |
| Wikipedia → | General | `/output/` (root) |

---

## See Also
- TOOLS.md - Directory Structure Reference
- AGENTS.md - Directory Awareness section
- /staging/README.md - Where to read source content
