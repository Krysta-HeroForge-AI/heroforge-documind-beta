#!/bin/bash
# Build Session 3 Complete Branch for DocuMind
# Run this from the root of your heroforge-documind repo
#
# Usage:
#   cd ~/heroforge-documind
#   chmod +x build-session-3.sh
#   ./build-session-3.sh

set -e

echo "🚀 Building session-3-complete branch..."

# Create branch
git checkout main
git pull origin main
git checkout -b session-3-complete

# Create directories
mkdir -p .claude/skills
mkdir -p .claude/subagents
mkdir -p docs/sample-docs
mkdir -p src/documind
mkdir -p tests

echo "📁 Creating skill: document-processor.md"
cat > .claude/skills/document-processor.md << 'SKILL_EOF'
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
SKILL_EOF

echo "📁 Creating subagent: summarizer.md"
cat > .claude/subagents/summarizer.md << 'SUBAGENT_EOF'
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
SUBAGENT_EOF

echo "📁 Creating hook: pre-commit-format.sh"
cat > .claude/hooks/pre-commit-format.sh << 'HOOK_EOF'
#!/bin/bash
# DocuMind Pre-Commit Format Hook
# Automatically formats files before commit

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[DocuMind] Running pre-commit formatting...${NC}"

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}[DocuMind] No staged files to format${NC}"
    exit 0
fi

FILES_MODIFIED=0

# Format Python files with black
PYTHON_FILES=$(echo "$STAGED_FILES" | grep -E '\.py$' || true)
if [ -n "$PYTHON_FILES" ]; then
    if command -v black &> /dev/null; then
        echo -e "${YELLOW}[DocuMind] Formatting Python files...${NC}"
        echo "$PYTHON_FILES" | xargs black --quiet 2>/dev/null || true
        FILES_MODIFIED=1
    fi
fi

# Clean up Markdown files
MD_FILES=$(echo "$STAGED_FILES" | grep -E '\.md$' || true)
if [ -n "$MD_FILES" ]; then
    echo -e "${YELLOW}[DocuMind] Cleaning up Markdown files...${NC}"
    for file in $MD_FILES; do
        if [ -f "$file" ]; then
            sed -i'' -e 's/[[:space:]]*$//' "$file" 2>/dev/null || true
            FILES_MODIFIED=1
        fi
    done
fi

if [ $FILES_MODIFIED -eq 1 ]; then
    echo "$STAGED_FILES" | xargs git add 2>/dev/null || true
    echo -e "${GREEN}[DocuMind] Files formatted and re-staged${NC}"
fi

echo -e "${GREEN}[DocuMind] Pre-commit formatting complete${NC}"
exit 0
HOOK_EOF
chmod +x .claude/hooks/pre-commit-format.sh

echo "📁 Creating sample doc: company-vacation-policy.md"
cat > docs/sample-docs/company-vacation-policy.md << 'SAMPLE1_EOF'
# Company Vacation Policy

**Effective Date:** January 1, 2024
**Last Updated:** November 24, 2024
**Department:** Human Resources

## Overview

This document outlines the vacation and paid time off (PTO) policy for all full-time employees.

## PTO Allowance

| Tenure | Annual PTO Days |
|--------|-----------------|
| 0-2 years | 15 days |
| 2-5 years | 20 days |
| 5-10 years | 25 days |
| 10+ years | 30 days |

## Requesting Time Off

1. Submit PTO request through the HR portal
2. Manager approval required within 5 business days
3. Requests should be submitted 2 weeks in advance

## Carryover Policy

- Maximum of **5 days** may be carried over to the next calendar year
- Carried over days must be used by March 31

## Contact

For questions: hr@company.com
SAMPLE1_EOF

echo "📁 Creating sample doc: engineering-deployment-guide.md"
cat > docs/sample-docs/engineering-deployment-guide.md << 'SAMPLE2_EOF'
# Engineering Deployment Guide

**Version:** 2.1.0
**Owner:** Platform Engineering Team

## Overview

This guide covers the standard deployment process for production applications.

## Prerequisites

- [ ] All tests pass in CI/CD pipeline
- [ ] Code review approved by 2+ engineers
- [ ] Security scan completed
- [ ] Rollback plan documented

## Deployment Process

### 1. Pre-Deployment

```bash
git checkout main
git pull origin main
npm test
npm run build
```

### 2. Create Release

```bash
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

### 3. Deploy to Production

Production requires manual approval via GitHub Actions.

## Rollback Procedure

```bash
kubectl rollout undo deployment/app -n production
```

## Contacts

- **On-Call:** #platform-oncall (Slack)
- **Emergency:** (555) 911-HELP
SAMPLE2_EOF

echo "📁 Creating requirements.txt"
cat > requirements.txt << 'REQ_EOF'
# DocuMind Dependencies - Session 3

# Core
python-dotenv>=1.0.0

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0

# Code Quality
black>=23.0.0
isort>=5.12.0

# Session 4+ Dependencies (uncomment as needed)
# supabase>=2.0.0          # Session 4
# openai>=1.0.0            # Session 5
# PyPDF2>=3.0.0            # Session 7
# pdfplumber>=0.10.0       # Session 7
# python-docx>=1.0.0       # Session 7
# pandas>=2.0.0            # Session 7
# ragas>=0.1.0             # Session 10
REQ_EOF

echo "📁 Creating src/documind/openrouter.py"
cat > src/documind/openrouter.py << 'OPENROUTER_EOF'
"""
DocuMind OpenRouter Client - Multi-model LLM gateway
Session 3: Foundation setup
"""

import os
import json
from typing import Optional, Dict, Any, List
from dataclasses import dataclass
import urllib.request
import urllib.error


@dataclass
class OpenRouterConfig:
    api_key: str
    default_model: str = "anthropic/claude-3.5-sonnet"
    base_url: str = "https://openrouter.ai/api/v1"
    max_tokens: int = 4096
    temperature: float = 0.7


class OpenRouterClient:
    """Client for OpenRouter multi-model API."""

    MODELS = {
        "anthropic/claude-3.5-sonnet": {"name": "Claude 3.5 Sonnet", "cost": "$$"},
        "anthropic/claude-3-haiku": {"name": "Claude 3 Haiku", "cost": "$"},
        "openai/gpt-4o": {"name": "GPT-4o", "cost": "$$"},
        "openai/gpt-4o-mini": {"name": "GPT-4o Mini", "cost": "$"},
        "google/gemini-pro-1.5": {"name": "Gemini Pro 1.5", "cost": "$$"},
    }

    def __init__(self, config: Optional[OpenRouterConfig] = None):
        if config:
            self.config = config
        else:
            api_key = os.getenv("OPENROUTER_API_KEY", "")
            self.config = OpenRouterConfig(api_key=api_key)

    def list_models(self) -> Dict[str, Dict[str, str]]:
        return self.MODELS

    def chat(
        self,
        message: str,
        context: Optional[str] = None,
        model: Optional[str] = None,
    ) -> Dict[str, Any]:
        model = model or self.config.default_model

        if not self.config.api_key:
            return {"success": False, "error": "OPENROUTER_API_KEY not configured"}

        messages = [{"role": "system", "content": self._system_prompt()}]
        if context:
            messages.append({"role": "user", "content": f"Context:\n{context}\n\n---\n\nQuestion:"})
        messages.append({"role": "user", "content": message})

        return self._request(messages, model)

    def _system_prompt(self) -> str:
        return """You are DocuMind, an intelligent assistant for company knowledge bases.
Answer questions accurately based on provided context. Always cite sources."""

    def _request(self, messages: List[Dict], model: str) -> Dict[str, Any]:
        url = f"{self.config.base_url}/chat/completions"
        payload = {"model": model, "messages": messages, "max_tokens": self.config.max_tokens}
        headers = {
            "Authorization": f"Bearer {self.config.api_key}",
            "Content-Type": "application/json",
        }

        try:
            data = json.dumps(payload).encode("utf-8")
            req = urllib.request.Request(url, data=data, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=60) as response:
                result = json.loads(response.read().decode("utf-8"))
                return {"success": True, "content": result["choices"][0]["message"]["content"]}
        except Exception as e:
            return {"success": False, "error": str(e)}


def get_client() -> OpenRouterClient:
    return OpenRouterClient()
OPENROUTER_EOF

echo "📁 Creating src/documind/document_processor.py"
cat > src/documind/document_processor.py << 'DOCPROC_EOF'
"""
DocuMind Document Processor
Session 3: Basic text/markdown support
Session 7: Extended with PDF, DOCX, XLSX
"""

import os
import json
import hashlib
from datetime import datetime
from typing import Optional, Dict, Any, Tuple
from dataclasses import dataclass, asdict
from pathlib import Path


@dataclass
class DocumentMetadata:
    title: str
    file_type: str
    file_size: int
    word_count: int
    char_count: int
    source_path: str
    created_at: str
    content_hash: str

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ProcessedDocument:
    id: str
    title: str
    content: str
    metadata: DocumentMetadata
    success: bool
    error: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id, "title": self.title, "content": self.content,
            "metadata": self.metadata.to_dict(), "success": self.success, "error": self.error
        }

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), indent=2)


class DocumentProcessor:
    """Process documents for DocuMind knowledge base."""

    SUPPORTED_TYPES = {
        ".txt": "text", ".md": "markdown", ".markdown": "markdown",
        ".pdf": "pdf", ".docx": "docx", ".xlsx": "xlsx", ".csv": "csv",
    }

    def __init__(self, base_path: Optional[str] = None):
        self.base_path = Path(base_path) if base_path else Path.cwd()

    def process_file(self, file_path: str) -> ProcessedDocument:
        path = self._resolve_path(file_path)

        if not path.exists():
            return self._error_result(file_path, f"File not found: {path}")
        if not path.is_file():
            return self._error_result(file_path, f"Not a file: {path}")

        file_type = self.SUPPORTED_TYPES.get(path.suffix.lower())
        if file_type is None:
            return self._error_result(file_path, f"Unsupported file type: {path.suffix}")

        try:
            content, title = self._extract_content(path, file_type)
        except Exception as e:
            return self._error_result(file_path, f"Extraction error: {str(e)}")

        metadata = self._generate_metadata(path, content, file_type)
        doc_id = f"doc_{hashlib.sha256(f'{path}:{content[:1000]}'.encode()).hexdigest()[:12]}"

        return ProcessedDocument(
            id=doc_id, title=title or path.stem, content=content,
            metadata=metadata, success=True
        )

    def process_content(self, content: str, title: str = "Untitled") -> ProcessedDocument:
        doc_id = f"doc_{hashlib.sha256(content.encode()).hexdigest()[:12]}"
        metadata = DocumentMetadata(
            title=title, file_type="text", file_size=len(content.encode()),
            word_count=len(content.split()), char_count=len(content),
            source_path="<direct_input>", created_at=datetime.utcnow().isoformat() + "Z",
            content_hash=hashlib.md5(content.encode()).hexdigest()
        )
        return ProcessedDocument(id=doc_id, title=title, content=content, metadata=metadata, success=True)

    def _resolve_path(self, file_path: str) -> Path:
        path = Path(file_path)
        return (self.base_path / path).resolve() if not path.is_absolute() else path.resolve()

    def _extract_content(self, path: Path, file_type: str) -> Tuple[str, Optional[str]]:
        if file_type in ("text", "markdown"):
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            title = None
            if file_type == "markdown":
                for line in content.split("\n"):
                    if line.strip().startswith("# "):
                        title = line.strip()[2:].strip()
                        break
            return content, title
        raise NotImplementedError(f"{file_type.upper()} extraction available in Session 7")

    def _generate_metadata(self, path: Path, content: str, file_type: str) -> DocumentMetadata:
        stat = path.stat()
        return DocumentMetadata(
            title=path.stem, file_type=file_type, file_size=stat.st_size,
            word_count=len(content.split()), char_count=len(content),
            source_path=str(path), created_at=datetime.fromtimestamp(stat.st_mtime).isoformat() + "Z",
            content_hash=hashlib.md5(content.encode()).hexdigest()
        )

    def _error_result(self, file_path: str, error: str) -> ProcessedDocument:
        return ProcessedDocument(
            id="", title=Path(file_path).stem, content="",
            metadata=DocumentMetadata("", "unknown", 0, 0, 0, file_path, datetime.utcnow().isoformat() + "Z", ""),
            success=False, error=error
        )


def process_document(file_path: str) -> ProcessedDocument:
    return DocumentProcessor().process_file(file_path)
DOCPROC_EOF

echo "📁 Updating src/documind/__init__.py"
cat > src/documind/__init__.py << 'INIT_EOF'
"""
DocuMind - AI-Powered Knowledge Management System

Session 3: Skills, Subagents, Hooks (Foundation)
"""

__version__ = "0.3.0"
__author__ = "HeroForge Course Students"

from .config import validate_config, get_env
from .document_processor import DocumentProcessor, ProcessedDocument, process_document
from .openrouter import OpenRouterClient, get_client

__all__ = [
    "validate_config", "get_env",
    "DocumentProcessor", "ProcessedDocument", "process_document",
    "OpenRouterClient", "get_client",
]
INIT_EOF

echo "📁 Creating tests/test_document_processor.py"
cat > tests/test_document_processor.py << 'TEST1_EOF'
"""Tests for DocuMind Document Processor - Session 3"""

import pytest
import tempfile
import os
from src.documind.document_processor import DocumentProcessor, process_document


class TestDocumentProcessor:
    def setup_method(self):
        self.processor = DocumentProcessor()
        self.temp_dir = tempfile.mkdtemp()

    def _create_temp_file(self, filename: str, content: str) -> str:
        filepath = os.path.join(self.temp_dir, filename)
        with open(filepath, "w") as f:
            f.write(content)
        return filepath

    def test_process_text_file(self):
        content = "This is a test document."
        filepath = self._create_temp_file("test.txt", content)
        result = self.processor.process_file(filepath)
        assert result.success is True
        assert result.content == content

    def test_process_markdown_file(self):
        content = "# My Title\n\nContent here."
        filepath = self._create_temp_file("test.md", content)
        result = self.processor.process_file(filepath)
        assert result.success is True
        assert result.title == "My Title"

    def test_process_nonexistent_file(self):
        result = self.processor.process_file("/nonexistent/file.txt")
        assert result.success is False
        assert "not found" in result.error.lower()

    def test_process_unsupported_type(self):
        filepath = self._create_temp_file("test.xyz", "content")
        result = self.processor.process_file(filepath)
        assert result.success is False
        assert "unsupported" in result.error.lower()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
TEST1_EOF

echo "📁 Creating tests/test_openrouter.py"
cat > tests/test_openrouter.py << 'TEST2_EOF'
"""Tests for DocuMind OpenRouter Client - Session 3"""

import pytest
from src.documind.openrouter import OpenRouterClient, OpenRouterConfig, get_client


class TestOpenRouterClient:
    def test_init_with_config(self):
        config = OpenRouterConfig(api_key="test-key")
        client = OpenRouterClient(config=config)
        assert client.config.api_key == "test-key"

    def test_list_models(self):
        client = OpenRouterClient(config=OpenRouterConfig(api_key="test"))
        models = client.list_models()
        assert "anthropic/claude-3.5-sonnet" in models
        assert "openai/gpt-4o" in models

    def test_chat_without_api_key(self):
        config = OpenRouterConfig(api_key="")
        client = OpenRouterClient(config=config)
        result = client.chat("Hello")
        assert result["success"] is False

    def test_get_client(self):
        client = get_client()
        assert isinstance(client, OpenRouterClient)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
TEST2_EOF

# Commit everything
echo "📦 Committing changes..."
git add -A
git commit -m "Session 3: Skills, Subagents, Hooks foundation

Features:
- Document Processor Skill
- Summarizer Subagent
- Pre-commit Format Hook
- OpenRouter multi-model client
- Document processor module
- Sample documents
- Test suite

🤖 Generated with Claude Code"

echo ""
echo "✅ session-3-complete branch created!"
echo ""
echo "To push to GitHub:"
echo "  git push origin session-3-complete"
echo ""
echo "To verify:"
echo "  python -c 'from src.documind import DocumentProcessor; print(\"OK\")'"
