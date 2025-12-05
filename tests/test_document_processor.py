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
