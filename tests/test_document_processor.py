"""Tests for DocuMind Document Processor - Session 3"""

import pytest
import tempfile
import os
import json
from src.documind.document_processor import (
    DocumentProcessor,
    process_document,
    DocumentMetadata,
    ProcessedDocument,
)


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

    def test_process_directory_not_file(self):
        """Test error when processing a directory instead of a file"""
        result = self.processor.process_file(self.temp_dir)
        assert result.success is False
        assert "not a file" in result.error.lower()

    def test_process_content_directly(self):
        """Test processing content without a file"""
        content = "Direct content test"
        result = self.processor.process_content(content, title="Test Title")
        assert result.success is True
        assert result.title == "Test Title"
        assert result.content == content
        assert result.metadata.source_path == "<direct_input>"

    def test_process_content_default_title(self):
        """Test processing content with default title"""
        result = self.processor.process_content("Some content")
        assert result.success is True
        assert result.title == "Untitled"

    def test_markdown_without_title(self):
        """Test markdown file without H1 header"""
        content = "Just some content without a title."
        filepath = self._create_temp_file("notitle.md", content)
        result = self.processor.process_file(filepath)
        assert result.success is True
        assert result.title == "notitle"  # Falls back to filename

    def test_to_json_method(self):
        """Test ProcessedDocument.to_json() method"""
        result = self.processor.process_content("Test content", "Test")
        json_str = result.to_json()
        assert isinstance(json_str, str)
        parsed = json.loads(json_str)
        assert parsed["title"] == "Test"
        assert parsed["success"] is True

    def test_metadata_to_dict(self):
        """Test DocumentMetadata.to_dict() method"""
        result = self.processor.process_content("Test content", "Test")
        metadata_dict = result.metadata.to_dict()
        assert isinstance(metadata_dict, dict)
        assert "title" in metadata_dict
        assert "file_type" in metadata_dict
        assert metadata_dict["title"] == "Test"

    def test_process_pdf_not_implemented(self):
        """Test that PDF processing shows not implemented error"""
        filepath = self._create_temp_file("test.pdf", "fake pdf content")
        result = self.processor.process_file(filepath)
        assert result.success is False
        assert "extraction" in result.error.lower()


class TestGlobalProcessFunction:
    def test_process_document_function(self):
        """Test the global process_document function"""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
            f.write("Test content")
            filepath = f.name

        try:
            result = process_document(filepath)
            assert result.success is True
            assert result.content == "Test content"
        finally:
            os.unlink(filepath)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
