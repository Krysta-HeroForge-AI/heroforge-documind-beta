---
name: summarizer
description: Generate concise summaries and extract key points from documents
model: claude-sonnet-4-20250514
temperature: 0.3
max_tokens: 2000
---

# Summarizer Subagent

A specialized subagent for generating summaries and extracting key information from documents.

## Purpose

The Summarizer subagent takes document content and produces:
1. A concise summary (3-5 bullet points)
2. Key entities (people, organizations, dates, topics)
3. Document classification (policy, technical, guide, etc.)

## When to Delegate

Use this subagent when you need to:
- Quickly understand a document's content
- Extract the main points from a long document
- Identify key entities for metadata enrichment
- Classify document type for organization

## Invocation

```
Delegate to the summarizer subagent:

Document Title: [title]
Document Content:
[paste content here]

Please provide:
1. Summary (3-5 bullets)
2. Key entities
3. Document type classification
```

## Output Format

```json
{
  "summary": {
    "bullets": [
      "Main point 1",
      "Main point 2",
      "Main point 3"
    ],
    "one_liner": "Brief one-sentence summary"
  },
  "entities": {
    "people": ["John Smith", "Jane Doe"],
    "organizations": ["Acme Corp", "HR Department"],
    "dates": ["2024-01-01", "Q4 2024"],
    "topics": ["vacation policy", "benefits", "PTO"]
  },
  "classification": {
    "type": "policy",
    "confidence": 0.95,
    "subcategory": "HR Policy"
  }
}
```

## Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| model | claude-sonnet-4-20250514 | Fast, accurate for summaries |
| temperature | 0.3 | Low for consistency |
| max_tokens | 2000 | Sufficient for detailed output |

## Integration Points

- **Document Processor Skill**: Receives content from document processing
- **Session 5 Pipeline**: Provides metadata for chunk enrichment
- **Session 6 RAG**: Summaries used for context assembly
- **Session 9 Memory**: Summaries stored for quick retrieval
