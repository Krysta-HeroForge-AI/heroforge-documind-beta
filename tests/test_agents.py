"""Tests for DocuMind Agents - Session 4"""

import pytest
from unittest.mock import Mock, patch, MagicMock


class TestUploaderAgent:
    """Test Uploader Agent (mocked - requires Supabase)."""

    @patch.dict('os.environ', {
        'SUPABASE_URL': 'https://test.supabase.co',
        'SUPABASE_SERVICE_KEY': 'test-key'
    })
    @patch('src.agents.uploader_agent.create_client')
    def test_upload_document(self, mock_client):
        """Test document upload."""
        from src.agents.uploader_agent import UploaderAgent

        # Mock Supabase response
        mock_supabase = MagicMock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [
            {"id": "test-uuid"}
        ]
        mock_client.return_value = mock_supabase

        agent = UploaderAgent()
        result = agent.upload_document(
            title="Test",
            content="Content",
            file_type="text"
        )

        assert result["success"] is True
        assert "document_id" in result


class TestVerifierAgent:
    """Test Verifier Agent (mocked - requires Supabase)."""

    @patch.dict('os.environ', {
        'SUPABASE_URL': 'https://test.supabase.co',
        'SUPABASE_SERVICE_KEY': 'test-key'
    })
    @patch('src.agents.verifier_agent.create_client')
    def test_verify_database_connection(self, mock_client):
        """Test database connection verification."""
        from src.agents.verifier_agent import VerifierAgent

        mock_supabase = MagicMock()
        mock_supabase.table.return_value.select.return_value.limit.return_value.execute.return_value = Mock()
        mock_client.return_value = mock_supabase

        agent = VerifierAgent()
        result = agent.verify_database_connection()

        assert result["success"] is True
        assert result["connected"] is True


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
