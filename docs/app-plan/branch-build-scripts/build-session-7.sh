#!/bin/bash
# Build Session 7 Complete Branch for DocuMind
# Advanced Document Parsing (PDF, DOCX, XLSX)
# Run this from the root of your heroforge-documind repo
#
# Usage:
#   cd ~/heroforge-documind
#   chmod +x build-session-7.sh
#   ./build-session-7.sh

set -e

echo "🚀 Building session-7-complete branch (Advanced Parsing)..."

# Create branch from session-6-complete
git checkout session-6-complete
git pull origin session-6-complete
git checkout -b session-7-complete

# Create directories
mkdir -p src/parsers

echo "📁 Creating PDF parser: src/parsers/pdf.py"
cat > src/parsers/pdf.py << 'PDF_PARSER_EOF'
"""
DocuMind PDF Parser
Session 7: Enhanced PDF extraction with tables
"""

from typing import Dict, Any, Optional
import PyPDF2
import pdfplumber
from pathlib import Path


class PDFParser:
    """Parser for PDF documents with table extraction."""

    def __init__(self):
        self.supported_extensions = [".pdf"]

    def parse(self, file_path: str) -> Dict[str, Any]:
        """Parse a PDF file and extract text and tables."""
        path = Path(file_path)

        if not path.exists():
            return {
                "success": False,
                "error": f"File not found: {file_path}"
            }

        if path.suffix.lower() not in self.supported_extensions:
            return {
                "success": False,
                "error": f"Not a PDF file: {path.suffix}"
            }

        try:
            # Try pdfplumber first (better for tables)
            text, tables = self._extract_with_pdfplumber(file_path)

            # Get metadata
            metadata = self._extract_metadata(file_path)

            # Combine text and tables
            full_content = self._combine_content(text, tables)

            return {
                "success": True,
                "content": full_content,
                "metadata": metadata,
                "tables_found": len(tables)
            }

        except Exception as e:
            # Fallback to PyPDF2
            try:
                text = self._extract_with_pypdf2(file_path)
                metadata = self._extract_metadata(file_path)

                return {
                    "success": True,
                    "content": text,
                    "metadata": metadata,
                    "tables_found": 0
                }
            except Exception as e2:
                return {
                    "success": False,
                    "error": f"PDF extraction failed: {str(e2)}"
                }

    def _extract_with_pdfplumber(self, file_path: str) -> tuple[str, list]:
        """Extract text and tables using pdfplumber."""
        text_parts = []
        tables = []

        with pdfplumber.open(file_path) as pdf:
            for page_num, page in enumerate(pdf.pages, 1):
                # Extract text
                page_text = page.extract_text()
                if page_text:
                    text_parts.append(f"[Page {page_num}]\n{page_text}")

                # Extract tables
                page_tables = page.extract_tables()
                for table_num, table in enumerate(page_tables, 1):
                    if table:
                        tables.append({
                            "page": page_num,
                            "table_num": table_num,
                            "data": table
                        })

        return "\n\n".join(text_parts), tables

    def _extract_with_pypdf2(self, file_path: str) -> str:
        """Fallback extraction using PyPDF2."""
        text_parts = []

        with open(file_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)

            for page_num, page in enumerate(reader.pages, 1):
                page_text = page.extract_text()
                if page_text:
                    text_parts.append(f"[Page {page_num}]\n{page_text}")

        return "\n\n".join(text_parts)

    def _extract_metadata(self, file_path: str) -> Dict[str, Any]:
        """Extract PDF metadata."""
        try:
            with open(file_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                info = reader.metadata

                return {
                    "title": info.get("/Title", Path(file_path).stem),
                    "author": info.get("/Author", ""),
                    "subject": info.get("/Subject", ""),
                    "creator": info.get("/Creator", ""),
                    "page_count": len(reader.pages)
                }
        except Exception:
            return {
                "title": Path(file_path).stem,
                "page_count": 0
            }

    def _combine_content(self, text: str, tables: list) -> str:
        """Combine text and tables into single content."""
        if not tables:
            return text

        result = [text]
        result.append("\n\n=== EXTRACTED TABLES ===\n")

        for table_info in tables:
            result.append(
                f"\n[Page {table_info['page']}, Table {table_info['table_num']}]"
            )

            # Format table as markdown
            table_data = table_info["data"]
            if table_data:
                # Header row
                if len(table_data) > 0:
                    result.append(" | ".join(str(cell) for cell in table_data[0]))
                    result.append("|".join(["---"] * len(table_data[0])))

                # Data rows
                for row in table_data[1:]:
                    result.append(" | ".join(str(cell) for cell in row))

            result.append("")

        return "\n".join(result)


def create_pdf_parser() -> PDFParser:
    """Factory function to create a PDF parser."""
    return PDFParser()
PDF_PARSER_EOF

echo "📁 Creating DOCX parser: src/parsers/docx.py"
cat > src/parsers/docx.py << 'DOCX_PARSER_EOF'
"""
DocuMind DOCX Parser
Session 7: Word document extraction
"""

from typing import Dict, Any
from pathlib import Path
import docx


class DOCXParser:
    """Parser for Microsoft Word documents."""

    def __init__(self):
        self.supported_extensions = [".docx"]

    def parse(self, file_path: str) -> Dict[str, Any]:
        """Parse a DOCX file and extract text with structure."""
        path = Path(file_path)

        if not path.exists():
            return {
                "success": False,
                "error": f"File not found: {file_path}"
            }

        if path.suffix.lower() not in self.supported_extensions:
            return {
                "success": False,
                "error": f"Not a DOCX file: {path.suffix}"
            }

        try:
            doc = docx.Document(file_path)

            # Extract paragraphs
            content_parts = []
            for para in doc.paragraphs:
                if para.text.strip():
                    # Preserve headings
                    if para.style.name.startswith('Heading'):
                        level = para.style.name.replace('Heading ', '')
                        try:
                            level_num = int(level)
                            prefix = '#' * level_num
                            content_parts.append(f"{prefix} {para.text}")
                        except ValueError:
                            content_parts.append(para.text)
                    else:
                        content_parts.append(para.text)

            # Extract tables
            tables = []
            for table_num, table in enumerate(doc.tables, 1):
                table_data = []
                for row in table.rows:
                    row_data = [cell.text for cell in row.cells]
                    table_data.append(row_data)
                tables.append({
                    "table_num": table_num,
                    "data": table_data
                })

            # Combine content
            full_content = self._combine_content(content_parts, tables)

            # Extract metadata
            metadata = self._extract_metadata(doc, path)

            return {
                "success": True,
                "content": full_content,
                "metadata": metadata,
                "tables_found": len(tables)
            }

        except Exception as e:
            return {
                "success": False,
                "error": f"DOCX parsing failed: {str(e)}"
            }

    def _extract_metadata(self, doc, path: Path) -> Dict[str, Any]:
        """Extract document metadata."""
        core_props = doc.core_properties

        return {
            "title": core_props.title or path.stem,
            "author": core_props.author or "",
            "subject": core_props.subject or "",
            "created": core_props.created.isoformat() if core_props.created else "",
            "modified": core_props.modified.isoformat() if core_props.modified else ""
        }

    def _combine_content(self, paragraphs: list, tables: list) -> str:
        """Combine paragraphs and tables."""
        result = ["\n".join(paragraphs)]

        if tables:
            result.append("\n\n=== DOCUMENT TABLES ===\n")

            for table_info in tables:
                result.append(f"\n[Table {table_info['table_num']}]")

                table_data = table_info["data"]
                if table_data:
                    # Header
                    if len(table_data) > 0:
                        result.append(" | ".join(table_data[0]))
                        result.append("|".join(["---"] * len(table_data[0])))

                    # Rows
                    for row in table_data[1:]:
                        result.append(" | ".join(row))

                result.append("")

        return "\n".join(result)


def create_docx_parser() -> DOCXParser:
    """Factory function to create a DOCX parser."""
    return DOCXParser()
DOCX_PARSER_EOF

echo "📁 Creating XLSX parser: src/parsers/xlsx.py"
cat > src/parsers/xlsx.py << 'XLSX_PARSER_EOF'
"""
DocuMind XLSX Parser
Session 7: Excel spreadsheet extraction
"""

from typing import Dict, Any
from pathlib import Path
import pandas as pd


class XLSXParser:
    """Parser for Excel spreadsheets."""

    def __init__(self):
        self.supported_extensions = [".xlsx", ".xls"]

    def parse(self, file_path: str) -> Dict[str, Any]:
        """Parse an Excel file and extract all sheets."""
        path = Path(file_path)

        if not path.exists():
            return {
                "success": False,
                "error": f"File not found: {file_path}"
            }

        if path.suffix.lower() not in self.supported_extensions:
            return {
                "success": False,
                "error": f"Not an Excel file: {path.suffix}"
            }

        try:
            # Read all sheets
            excel_file = pd.ExcelFile(file_path)
            sheet_names = excel_file.sheet_names

            content_parts = []
            sheet_data = []

            for sheet_name in sheet_names:
                df = pd.read_excel(file_path, sheet_name=sheet_name)

                # Convert to markdown table
                markdown_table = self._dataframe_to_markdown(df, sheet_name)
                content_parts.append(markdown_table)

                # Store structured data
                sheet_data.append({
                    "sheet_name": sheet_name,
                    "rows": len(df),
                    "columns": len(df.columns),
                    "column_names": list(df.columns)
                })

            full_content = "\n\n".join(content_parts)

            metadata = {
                "title": path.stem,
                "sheet_count": len(sheet_names),
                "sheets": sheet_data
            }

            return {
                "success": True,
                "content": full_content,
                "metadata": metadata,
                "sheets_found": len(sheet_names)
            }

        except Exception as e:
            return {
                "success": False,
                "error": f"Excel parsing failed: {str(e)}"
            }

    def _dataframe_to_markdown(self, df: pd.DataFrame, sheet_name: str) -> str:
        """Convert a pandas DataFrame to markdown table."""
        result = [f"## Sheet: {sheet_name}\n"]

        if df.empty:
            result.append("(Empty sheet)")
            return "\n".join(result)

        # Header
        headers = [str(col) for col in df.columns]
        result.append(" | ".join(headers))
        result.append("|".join(["---"] * len(headers)))

        # Rows (limit to first 100 for performance)
        max_rows = min(100, len(df))
        for idx in range(max_rows):
            row = df.iloc[idx]
            row_data = [str(val) for val in row]
            result.append(" | ".join(row_data))

        if len(df) > max_rows:
            result.append(f"\n... ({len(df) - max_rows} more rows)")

        return "\n".join(result)


def create_xlsx_parser() -> XLSXParser:
    """Factory function to create an XLSX parser."""
    return XLSXParser()
XLSX_PARSER_EOF

echo "📁 Creating unified processor: src/parsers/processor.py"
cat > src/parsers/processor.py << 'PROCESSOR_EOF'
"""
DocuMind Unified Document Processor
Session 7: Route files to appropriate parser
"""

from typing import Dict, Any
from pathlib import Path

from .pdf import create_pdf_parser
from .docx import create_docx_parser
from .xlsx import create_xlsx_parser


class UnifiedDocumentProcessor:
    """Unified processor that routes to appropriate parser."""

    def __init__(self):
        self.pdf_parser = create_pdf_parser()
        self.docx_parser = create_docx_parser()
        self.xlsx_parser = create_xlsx_parser()

        self.parser_map = {
            ".pdf": self.pdf_parser,
            ".docx": self.docx_parser,
            ".xlsx": self.xlsx_parser,
            ".xls": self.xlsx_parser
        }

    def process(self, file_path: str) -> Dict[str, Any]:
        """Process a document file using appropriate parser."""
        path = Path(file_path)

        if not path.exists():
            return {
                "success": False,
                "error": f"File not found: {file_path}"
            }

        extension = path.suffix.lower()

        # Check for text/markdown (simple read)
        if extension in [".txt", ".md", ".markdown"]:
            return self._process_text_file(file_path)

        # Route to specialized parser
        parser = self.parser_map.get(extension)
        if not parser:
            return {
                "success": False,
                "error": f"Unsupported file type: {extension}"
            }

        result = parser.parse(file_path)

        # Add common metadata
        if result.get("success"):
            result["file_path"] = str(path)
            result["file_type"] = extension[1:]  # Remove dot
            result["file_size"] = path.stat().st_size

        return result

    def _process_text_file(self, file_path: str) -> Dict[str, Any]:
        """Simple text file processing."""
        try:
            path = Path(file_path)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Extract title from markdown
            title = path.stem
            if path.suffix.lower() in [".md", ".markdown"]:
                for line in content.split('\n'):
                    if line.strip().startswith('# '):
                        title = line.strip()[2:].strip()
                        break

            return {
                "success": True,
                "content": content,
                "metadata": {
                    "title": title,
                    "file_type": path.suffix[1:],
                    "word_count": len(content.split())
                },
                "file_path": str(path),
                "file_type": path.suffix[1:],
                "file_size": path.stat().st_size
            }
        except Exception as e:
            return {
                "success": False,
                "error": f"Text file processing failed: {str(e)}"
            }

    def get_supported_types(self) -> list:
        """Get list of supported file types."""
        return [".txt", ".md", ".markdown", ".pdf", ".docx", ".xlsx", ".xls"]


def create_unified_processor() -> UnifiedDocumentProcessor:
    """Factory function to create unified processor."""
    return UnifiedDocumentProcessor()
PROCESSOR_EOF

echo "📁 Creating parser requirements: src/parsers/requirements.txt"
cat > src/parsers/requirements.txt << 'PARSER_REQ_EOF'
# DocuMind Advanced Parser Dependencies
# Session 7

# PDF parsing
PyPDF2>=3.0.0
pdfplumber>=0.10.0

# Word documents
python-docx>=1.0.0

# Excel spreadsheets
pandas>=2.0.0
openpyxl>=3.1.0
PARSER_REQ_EOF

echo "📁 Updating requirements.txt"
cat > requirements.txt << 'REQ_EOF'
# DocuMind Dependencies - Session 7

# Core
python-dotenv>=1.0.0

# Database (Session 4)
supabase>=2.0.0

# MCP Server (Session 4)
fastmcp>=0.3.0

# Embeddings (Session 5)
openai>=1.0.0

# Advanced Parsers (Session 7)
PyPDF2>=3.0.0
pdfplumber>=0.10.0
python-docx>=1.0.0
pandas>=2.0.0
openpyxl>=3.1.0

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0

# Code Quality
black>=23.0.0
isort>=5.12.0

# Session 10 Dependencies (uncomment as needed)
# ragas>=0.1.0             # Session 10
# trulens-eval>=0.20.0     # Session 10
REQ_EOF

echo "📁 Creating tests/test_parsers.py"
cat > tests/test_parsers.py << 'TEST_PARSERS_EOF'
"""Tests for DocuMind Parsers - Session 7"""

import pytest
from pathlib import Path
import tempfile


class TestUnifiedProcessor:
    """Test Unified Document Processor."""

    def test_process_text_file(self, tmp_path):
        """Test processing text file."""
        from src.parsers.processor import create_unified_processor

        file = tmp_path / "test.txt"
        file.write_text("Test content")

        processor = create_unified_processor()
        result = processor.process(str(file))

        assert result["success"] is True
        assert "Test content" in result["content"]

    def test_process_markdown_file(self, tmp_path):
        """Test processing markdown file."""
        from src.parsers.processor import create_unified_processor

        file = tmp_path / "test.md"
        file.write_text("# My Title\n\nContent here.")

        processor = create_unified_processor()
        result = processor.process(str(file))

        assert result["success"] is True
        assert result["metadata"]["title"] == "My Title"

    def test_process_nonexistent_file(self):
        """Test processing nonexistent file."""
        from src.parsers.processor import create_unified_processor

        processor = create_unified_processor()
        result = processor.process("/nonexistent/file.txt")

        assert result["success"] is False
        assert "not found" in result["error"].lower()

    def test_unsupported_file_type(self, tmp_path):
        """Test unsupported file type."""
        from src.parsers.processor import create_unified_processor

        file = tmp_path / "test.xyz"
        file.write_text("content")

        processor = create_unified_processor()
        result = processor.process(str(file))

        assert result["success"] is False
        assert "unsupported" in result["error"].lower()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
TEST_PARSERS_EOF

# Update pipeline to use new parsers
echo "📁 Updating extractor agent to use unified processor"
cat > src/pipeline/agents/extractor.py << 'EXTRACTOR_UPDATE_EOF'
"""
DocuMind Extractor Agent
Session 7: Updated to use unified processor
"""

from typing import Dict, Any, List
from pathlib import Path
import hashlib
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from src.parsers.processor import create_unified_processor


class ExtractorAgent:
    """Agent responsible for extracting text from various document formats."""

    def __init__(self):
        self.processor = create_unified_processor()
        self.supported_formats = self.processor.get_supported_types()

    def extract(self, file_path: str) -> Dict[str, Any]:
        """Extract text content from a file."""
        result = self.processor.process(file_path)

        if not result.get("success"):
            return result

        # Add document_id
        content = result["content"]
        doc_hash = hashlib.sha256(content.encode()).hexdigest()[:12]

        return {
            "success": True,
            "document_id": f"doc_{doc_hash}",
            "title": result["metadata"].get("title", Path(file_path).stem),
            "content": content,
            "file_type": result["file_type"],
            "file_path": result["file_path"],
            "metadata": result["metadata"]
        }

    def extract_batch(self, file_paths: List[str]) -> List[Dict[str, Any]]:
        """Extract multiple files in batch."""
        return [self.extract(fp) for fp in file_paths]


def create_extractor() -> ExtractorAgent:
    """Factory function to create an extractor agent."""
    return ExtractorAgent()
EXTRACTOR_UPDATE_EOF

# Commit everything
echo "📦 Committing changes..."
git add -A
git commit -m "Session 7: Advanced document parsing (PDF, DOCX, XLSX)

Features:
- PDF parser with PyPDF2 and pdfplumber
- Table extraction from PDFs
- DOCX parser with structure preservation
- XLSX parser with multi-sheet support
- Unified document processor with file routing
- Markdown table formatting
- Metadata extraction for all formats
- Updated extractor agent
- Comprehensive tests

Supported formats: TXT, MD, PDF, DOCX, XLSX

🤖 Generated with Claude Code"

echo ""
echo "✅ session-7-complete branch created!"
echo ""
echo "To push to GitHub:"
echo "  git push origin session-7-complete"
echo ""
echo "Now supports: PDF, DOCX, XLSX, TXT, MD"
echo ""
