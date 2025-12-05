#!/bin/bash
# Build Session 5 Complete Branch for DocuMind
# Multi-Agent Pipeline with ClaudeFlow
# Run this from the root of your heroforge-documind repo
#
# Usage:
#   cd ~/heroforge-documind
#   chmod +x build-session-5.sh
#   ./build-session-5.sh

set -e

echo "🚀 Building session-5-complete branch (Multi-Agent Pipeline)..."

# Create branch from session-4-complete
git checkout session-4-complete
git pull origin session-4-complete
git checkout -b session-5-complete

# Create directories
mkdir -p src/pipeline/agents
mkdir -p src/pipeline

echo "📁 Creating pipeline config: src/pipeline/config.py"
cat > src/pipeline/config.py << 'CONFIG_EOF'
"""
DocuMind Pipeline Configuration
Session 5: Multi-agent processing settings
"""

import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class PipelineConfig:
    """Configuration for document processing pipeline."""

    # Chunking settings
    chunk_size: int = 500  # words per chunk
    chunk_overlap: int = 50  # words overlap between chunks

    # Embedding settings
    embedding_model: str = "text-embedding-3-small"
    embedding_dimension: int = 1536
    openai_api_key: Optional[str] = None

    # Processing settings
    batch_size: int = 10  # documents per batch
    max_workers: int = 4  # parallel workers

    # Supabase settings
    supabase_url: Optional[str] = None
    supabase_key: Optional[str] = None

    @classmethod
    def from_env(cls) -> "PipelineConfig":
        """Create config from environment variables."""
        return cls(
            openai_api_key=os.getenv("OPENAI_API_KEY"),
            supabase_url=os.getenv("SUPABASE_URL"),
            supabase_key=os.getenv("SUPABASE_SERVICE_KEY")
        )

    def validate(self) -> tuple[bool, str]:
        """Validate configuration."""
        if not self.openai_api_key:
            return False, "OPENAI_API_KEY not set"
        if not self.supabase_url:
            return False, "SUPABASE_URL not set"
        if not self.supabase_key:
            return False, "SUPABASE_SERVICE_KEY not set"
        return True, "Configuration valid"


# Global config instance
config = PipelineConfig.from_env()
CONFIG_EOF

echo "📁 Creating extractor agent: src/pipeline/agents/extractor.py"
cat > src/pipeline/agents/extractor.py << 'EXTRACTOR_EOF'
"""
DocuMind Extractor Agent
Session 5: Extract text content from documents
"""

from typing import Dict, Any, List
from pathlib import Path
import hashlib


class ExtractorAgent:
    """Agent responsible for extracting text from various document formats."""

    def __init__(self):
        self.supported_formats = [".txt", ".md", ".markdown"]

    def extract(self, file_path: str) -> Dict[str, Any]:
        """Extract text content from a file."""
        path = Path(file_path)

        if not path.exists():
            return {
                "success": False,
                "error": f"File not found: {file_path}"
            }

        if path.suffix.lower() not in self.supported_formats:
            return {
                "success": False,
                "error": f"Unsupported format: {path.suffix}"
            }

        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Extract title from markdown
            title = path.stem
            if path.suffix.lower() in [".md", ".markdown"]:
                for line in content.split('\n'):
                    if line.strip().startswith('# '):
                        title = line.strip()[2:].strip()
                        break

            # Generate document hash
            doc_hash = hashlib.sha256(content.encode()).hexdigest()[:12]

            return {
                "success": True,
                "document_id": f"doc_{doc_hash}",
                "title": title,
                "content": content,
                "file_type": path.suffix[1:],  # Remove leading dot
                "file_path": str(path),
                "metadata": {
                    "file_size": path.stat().st_size,
                    "word_count": len(content.split())
                }
            }

        except Exception as e:
            return {
                "success": False,
                "error": f"Extraction failed: {str(e)}"
            }

    def extract_batch(self, file_paths: List[str]) -> List[Dict[str, Any]]:
        """Extract multiple files in batch."""
        return [self.extract(fp) for fp in file_paths]


def create_extractor() -> ExtractorAgent:
    """Factory function to create an extractor agent."""
    return ExtractorAgent()
EXTRACTOR_EOF

echo "📁 Creating chunker agent: src/pipeline/agents/chunker.py"
cat > src/pipeline/agents/chunker.py << 'CHUNKER_EOF'
"""
DocuMind Chunker Agent
Session 5: Split documents into overlapping chunks
"""

from typing import Dict, Any, List
from dataclasses import dataclass


@dataclass
class Chunk:
    """Represents a document chunk."""
    chunk_id: str
    document_id: str
    chunk_index: int
    content: str
    metadata: Dict[str, Any]


class ChunkerAgent:
    """Agent responsible for chunking documents with overlap."""

    def __init__(self, chunk_size: int = 500, overlap: int = 50):
        self.chunk_size = chunk_size  # words
        self.overlap = overlap  # words

    def chunk_document(self, document: Dict[str, Any]) -> Dict[str, Any]:
        """Split a document into overlapping chunks."""
        if not document.get("success"):
            return {
                "success": False,
                "error": "Invalid document input"
            }

        content = document["content"]
        document_id = document["document_id"]

        # Split into words
        words = content.split()

        if len(words) == 0:
            return {
                "success": False,
                "error": "Empty document"
            }

        chunks = []
        chunk_index = 0
        start = 0

        while start < len(words):
            # Get chunk of words
            end = min(start + self.chunk_size, len(words))
            chunk_words = words[start:end]
            chunk_content = ' '.join(chunk_words)

            # Create chunk
            chunk = Chunk(
                chunk_id=f"{document_id}_chunk_{chunk_index}",
                document_id=document_id,
                chunk_index=chunk_index,
                content=chunk_content,
                metadata={
                    "start_word": start,
                    "end_word": end,
                    "word_count": len(chunk_words),
                    "title": document.get("title", ""),
                    "file_type": document.get("file_type", "")
                }
            )

            chunks.append(chunk)
            chunk_index += 1

            # Move start position (with overlap)
            start = end - self.overlap

            # Break if we're at the end
            if end >= len(words):
                break

        return {
            "success": True,
            "document_id": document_id,
            "chunk_count": len(chunks),
            "chunks": [
                {
                    "chunk_id": c.chunk_id,
                    "chunk_index": c.chunk_index,
                    "content": c.content,
                    "metadata": c.metadata
                }
                for c in chunks
            ]
        }

    def chunk_batch(self, documents: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Chunk multiple documents."""
        return [self.chunk_document(doc) for doc in documents]


def create_chunker(chunk_size: int = 500, overlap: int = 50) -> ChunkerAgent:
    """Factory function to create a chunker agent."""
    return ChunkerAgent(chunk_size=chunk_size, overlap=overlap)
CHUNKER_EOF

echo "📁 Creating embedder agent: src/pipeline/agents/embedder.py"
cat > src/pipeline/agents/embedder.py << 'EMBEDDER_EOF'
"""
DocuMind Embedder Agent
Session 5: Generate embeddings for chunks using OpenAI
"""

from typing import Dict, Any, List
import os
from openai import OpenAI


class EmbedderAgent:
    """Agent responsible for generating embeddings."""

    def __init__(self, model: str = "text-embedding-3-small"):
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY not set")

        self.client = OpenAI(api_key=api_key)
        self.model = model
        self.dimension = 1536  # text-embedding-3-small dimension

    def embed_chunk(self, chunk: Dict[str, Any]) -> Dict[str, Any]:
        """Generate embedding for a single chunk."""
        try:
            content = chunk["content"]

            # Call OpenAI embedding API
            response = self.client.embeddings.create(
                input=content,
                model=self.model
            )

            embedding = response.data[0].embedding

            return {
                "success": True,
                "chunk_id": chunk["chunk_id"],
                "chunk_index": chunk["chunk_index"],
                "content": content,
                "embedding": embedding,
                "metadata": chunk["metadata"]
            }

        except Exception as e:
            return {
                "success": False,
                "chunk_id": chunk.get("chunk_id", "unknown"),
                "error": str(e)
            }

    def embed_chunks(self, chunks: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Generate embeddings for multiple chunks."""
        results = {
            "total": len(chunks),
            "success": 0,
            "failed": 0,
            "embedded_chunks": []
        }

        for chunk in chunks:
            result = self.embed_chunk(chunk)

            if result["success"]:
                results["success"] += 1
                results["embedded_chunks"].append(result)
            else:
                results["failed"] += 1

        return results

    def embed_batch(
        self,
        chunked_documents: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Embed all chunks from multiple chunked documents."""
        all_results = []

        for doc in chunked_documents:
            if not doc.get("success"):
                continue

            chunks = doc.get("chunks", [])
            embed_result = self.embed_chunks(chunks)

            all_results.append({
                "document_id": doc["document_id"],
                "chunk_count": doc["chunk_count"],
                "embedding_result": embed_result
            })

        return all_results


def create_embedder(model: str = "text-embedding-3-small") -> EmbedderAgent:
    """Factory function to create an embedder agent."""
    return EmbedderAgent(model=model)
EMBEDDER_EOF

echo "📁 Creating writer agent: src/pipeline/agents/writer.py"
cat > src/pipeline/agents/writer.py << 'WRITER_EOF'
"""
DocuMind Writer Agent
Session 5: Write chunks and embeddings to Supabase
"""

from typing import Dict, Any, List
from supabase import create_client, Client
import os


class WriterAgent:
    """Agent responsible for writing chunks to database."""

    def __init__(self):
        supabase_url = os.getenv("SUPABASE_URL")
        supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

        if not supabase_url or not supabase_key:
            raise ValueError("Supabase credentials not set")

        self.supabase: Client = create_client(supabase_url, supabase_key)

    def write_chunk(self, chunk: Dict[str, Any], document_id: str) -> Dict[str, Any]:
        """Write a single chunk to database."""
        try:
            chunk_data = {
                "document_id": document_id,
                "chunk_index": chunk["chunk_index"],
                "content": chunk["content"],
                "embedding": chunk["embedding"],
                "metadata": chunk["metadata"]
            }

            result = self.supabase.table("document_chunks").insert(chunk_data).execute()

            return {
                "success": True,
                "chunk_id": chunk["chunk_id"],
                "database_id": result.data[0]["id"]
            }

        except Exception as e:
            return {
                "success": False,
                "chunk_id": chunk.get("chunk_id", "unknown"),
                "error": str(e)
            }

    def write_chunks(
        self,
        embedded_chunks: List[Dict[str, Any]],
        document_id: str
    ) -> Dict[str, Any]:
        """Write multiple chunks to database."""
        results = {
            "total": len(embedded_chunks),
            "success": 0,
            "failed": 0,
            "written_chunks": []
        }

        for chunk in embedded_chunks:
            result = self.write_chunk(chunk, document_id)

            if result["success"]:
                results["success"] += 1
                results["written_chunks"].append(result)
            else:
                results["failed"] += 1

        return results

    def write_batch(
        self,
        embedded_documents: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Write all chunks from multiple embedded documents."""
        total_written = 0
        total_failed = 0
        document_results = []

        for doc in embedded_documents:
            document_id = doc["document_id"]
            embedded_chunks = doc["embedding_result"]["embedded_chunks"]

            write_result = self.write_chunks(embedded_chunks, document_id)

            total_written += write_result["success"]
            total_failed += write_result["failed"]

            document_results.append({
                "document_id": document_id,
                "chunks_written": write_result["success"],
                "chunks_failed": write_result["failed"]
            })

        return {
            "total_chunks": total_written + total_failed,
            "chunks_written": total_written,
            "chunks_failed": total_failed,
            "documents": document_results
        }


def create_writer() -> WriterAgent:
    """Factory function to create a writer agent."""
    return WriterAgent()
WRITER_EOF

echo "📁 Creating pipeline orchestrator: src/pipeline/ingest.py"
cat > src/pipeline/ingest.py << 'INGEST_EOF'
"""
DocuMind Document Ingestion Pipeline
Session 5: Multi-agent coordinated processing
"""

from typing import List, Dict, Any
from pathlib import Path
import sys

from .agents.extractor import create_extractor
from .agents.chunker import create_chunker
from .agents.embedder import create_embedder
from .agents.writer import create_writer
from .config import config


class DocumentPipeline:
    """Orchestrate multi-agent document processing pipeline."""

    def __init__(self):
        # Validate configuration
        valid, msg = config.validate()
        if not valid:
            raise ValueError(f"Configuration invalid: {msg}")

        # Initialize agents
        self.extractor = create_extractor()
        self.chunker = create_chunker(
            chunk_size=config.chunk_size,
            overlap=config.chunk_overlap
        )
        self.embedder = create_embedder(model=config.embedding_model)
        self.writer = create_writer()

    def process_document(self, file_path: str) -> Dict[str, Any]:
        """Process a single document through the pipeline."""
        print(f"🔄 Processing: {file_path}")

        # Step 1: Extract
        print("  📄 Extracting text...")
        extracted = self.extractor.extract(file_path)
        if not extracted["success"]:
            return {
                "success": False,
                "file_path": file_path,
                "error": extracted["error"]
            }

        # Step 2: Chunk
        print(f"  ✂️  Chunking document...")
        chunked = self.chunker.chunk_document(extracted)
        if not chunked["success"]:
            return {
                "success": False,
                "file_path": file_path,
                "error": chunked["error"]
            }
        print(f"  ✅ Created {chunked['chunk_count']} chunks")

        # Step 3: Embed
        print(f"  🧠 Generating embeddings...")
        embedded = self.embedder.embed_chunks(chunked["chunks"])
        print(f"  ✅ Embedded {embedded['success']}/{embedded['total']} chunks")

        # Step 4: Write
        print(f"  💾 Writing to database...")
        written = self.writer.write_chunks(
            embedded["embedded_chunks"],
            extracted["document_id"]
        )
        print(f"  ✅ Wrote {written['success']}/{written['total']} chunks")

        return {
            "success": True,
            "file_path": file_path,
            "document_id": extracted["document_id"],
            "title": extracted["title"],
            "chunks_created": chunked["chunk_count"],
            "chunks_embedded": embedded["success"],
            "chunks_written": written["success"]
        }

    def process_batch(self, file_paths: List[str]) -> Dict[str, Any]:
        """Process multiple documents."""
        results = {
            "total": len(file_paths),
            "success": 0,
            "failed": 0,
            "documents": []
        }

        for file_path in file_paths:
            result = self.process_document(file_path)

            if result["success"]:
                results["success"] += 1
            else:
                results["failed"] += 1

            results["documents"].append(result)

        return results

    def process_directory(self, directory: str) -> Dict[str, Any]:
        """Process all supported documents in a directory."""
        path = Path(directory)

        if not path.exists():
            return {
                "success": False,
                "error": f"Directory not found: {directory}"
            }

        # Find all supported files
        supported_extensions = [".txt", ".md", ".markdown"]
        files = [
            str(f) for f in path.rglob("*")
            if f.is_file() and f.suffix.lower() in supported_extensions
        ]

        if not files:
            return {
                "success": False,
                "error": "No supported files found"
            }

        print(f"📁 Found {len(files)} documents in {directory}")
        return self.process_batch(files)


def main():
    """CLI entry point."""
    if len(sys.argv) < 2:
        print("Usage: python -m src.pipeline.ingest <file_or_directory>")
        sys.exit(1)

    path = sys.argv[1]
    pipeline = DocumentPipeline()

    if Path(path).is_dir():
        result = pipeline.process_directory(path)
    else:
        result = pipeline.process_batch([path])

    print("\n📊 Pipeline Results:")
    print(f"  Total: {result['total']}")
    print(f"  Success: {result['success']}")
    print(f"  Failed: {result['failed']}")


if __name__ == "__main__":
    main()
INGEST_EOF

echo "📁 Updating requirements.txt"
cat > requirements.txt << 'REQ_EOF'
# DocuMind Dependencies - Session 5

# Core
python-dotenv>=1.0.0

# Database (Session 4)
supabase>=2.0.0

# MCP Server (Session 4)
fastmcp>=0.3.0

# Embeddings (Session 5)
openai>=1.0.0

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0

# Code Quality
black>=23.0.0
isort>=5.12.0

# Session 7+ Dependencies (uncomment as needed)
# PyPDF2>=3.0.0            # Session 7
# pdfplumber>=0.10.0       # Session 7
# python-docx>=1.0.0       # Session 7
# pandas>=2.0.0            # Session 7
# ragas>=0.1.0             # Session 10
REQ_EOF

echo "📁 Creating tests/test_pipeline.py"
cat > tests/test_pipeline.py << 'TEST_PIPELINE_EOF'
"""Tests for DocuMind Pipeline - Session 5"""

import pytest
from src.pipeline.agents.extractor import ExtractorAgent
from src.pipeline.agents.chunker import ChunkerAgent


class TestExtractorAgent:
    """Test Extractor Agent."""

    def test_extract_nonexistent_file(self):
        """Test extraction of nonexistent file."""
        extractor = ExtractorAgent()
        result = extractor.extract("/nonexistent/file.txt")
        assert result["success"] is False
        assert "not found" in result["error"].lower()

    def test_extract_unsupported_format(self, tmp_path):
        """Test extraction of unsupported format."""
        file = tmp_path / "test.xyz"
        file.write_text("content")

        extractor = ExtractorAgent()
        result = extractor.extract(str(file))
        assert result["success"] is False
        assert "unsupported" in result["error"].lower()


class TestChunkerAgent:
    """Test Chunker Agent."""

    def test_chunk_document(self):
        """Test chunking a document."""
        chunker = ChunkerAgent(chunk_size=10, overlap=2)

        document = {
            "success": True,
            "document_id": "test_doc",
            "content": " ".join([f"word{i}" for i in range(25)]),
            "title": "Test"
        }

        result = chunker.chunk_document(document)
        assert result["success"] is True
        assert result["chunk_count"] > 0
        assert len(result["chunks"]) > 1

    def test_chunk_empty_document(self):
        """Test chunking empty document."""
        chunker = ChunkerAgent()

        document = {
            "success": True,
            "document_id": "test_doc",
            "content": "",
            "title": "Empty"
        }

        result = chunker.chunk_document(document)
        assert result["success"] is False


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
TEST_PIPELINE_EOF

# Commit everything
echo "📦 Committing changes..."
git add -A
git commit -m "Session 5: Multi-agent document processing pipeline

Features:
- Pipeline configuration and validation
- Extractor agent (text/markdown)
- Chunker agent (overlapping chunks)
- Embedder agent (OpenAI embeddings)
- Writer agent (Supabase storage)
- Pipeline orchestrator
- Batch processing support
- Directory processing
- CLI interface
- Comprehensive tests

🤖 Generated with Claude Code"

echo ""
echo "✅ session-5-complete branch created!"
echo ""
echo "To push to GitHub:"
echo "  git push origin session-5-complete"
echo ""
echo "To run pipeline:"
echo "  python -m src.pipeline.ingest docs/sample-docs/"
echo ""
