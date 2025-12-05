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
