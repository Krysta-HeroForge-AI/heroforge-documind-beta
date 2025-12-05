---
name: document-processor
description: Process uploaded documents - extract text, metadata, and prepare for chunking
triggers:
  - "process document"
  - "process file"
  - "upload document"
  - "ingest document"
---

# Document Processor Skill

This skill processes uploaded documents for the DocuMind knowledge base.

## What This Skill Does

1. **Accepts** a file path or document content
2. **Extracts** text content based on file type
3. **Extracts** metadata (title, author, date, file type)
4. **Prepares** content for chunking and embedding (Session 5+)
5. **Returns** structured output for downstream processing

## Usage

```
/skill document-processor

Then provide:
- File path: /path/to/document.pdf
- Or paste document content directly
```

## Supported File Types

| Type | Extension | Status |
|------|-----------|--------|
| Plain Text | .txt | Supported |
| Markdown | .md | Supported |
| PDF | .pdf | Session 7 |
| Word | .docx | Session 7 |
| Excel | .xlsx | Session 7 |

## Processing Steps

### Step 1: File Type Detection
Determine the file type from extension or content inspection.

### Step 2: Text Extraction
Extract raw text content using appropriate parser:
- `.txt` / `.md`: Direct read
- `.pdf`: PyPDF2 or pdfplumber (Session 7)
- `.docx`: python-docx (Session 7)

### Step 3: Metadata Extraction
Extract and structure metadata:
```json
{
  "title": "Document Title",
  "file_type": "markdown",
  "file_size": 1234,
  "word_count": 500,
  "created_at": "2024-11-24T10:00:00Z",
  "source_path": "/docs/sample.md"
}
```

### Step 4: Content Preparation
Prepare content for downstream processing:
- Clean whitespace and formatting
- Preserve structure (headings, lists)
- Mark section boundaries

## Output Format

```json
{
  "success": true,
  "document": {
    "id": "doc_abc123",
    "title": "Sample Document",
    "content": "Full extracted text...",
    "metadata": {
      "file_type": "markdown",
      "word_count": 500,
      "source_path": "/docs/sample.md"
    }
  },
  "ready_for_chunking": true
}
```

## Integration Points

- **Session 5**: Feeds into multi-agent chunking pipeline
- **Session 6**: Provides content for RAG queries
- **Session 7**: Extended with advanced parsers
