"""Tests for DocuMind OpenRouter Client - Session 3"""

import pytest
import os
from unittest.mock import patch, MagicMock
from src.documind.openrouter import OpenRouterClient, OpenRouterConfig, get_client


class TestOpenRouterClient:
    def test_init_with_config(self):
        config = OpenRouterConfig(api_key="test-key")
        client = OpenRouterClient(config=config)
        assert client.config.api_key == "test-key"

    def test_init_without_config(self):
        """Test initialization from environment variable"""
        os.environ["OPENROUTER_API_KEY"] = "env-key-123"
        client = OpenRouterClient()
        assert client.config.api_key == "env-key-123"
        del os.environ["OPENROUTER_API_KEY"]

    def test_list_models(self):
        client = OpenRouterClient(config=OpenRouterConfig(api_key="test"))
        models = client.list_models()
        assert "anthropic/claude-3.5-sonnet" in models
        assert "openai/gpt-4o" in models
        assert len(models) >= 5

    def test_chat_without_api_key(self):
        config = OpenRouterConfig(api_key="")
        client = OpenRouterClient(config=config)
        result = client.chat("Hello")
        assert result["success"] is False
        assert "OPENROUTER_API_KEY not configured" in result["error"]

    def test_chat_with_context(self):
        """Test chat method with context parameter"""
        config = OpenRouterConfig(api_key="")
        client = OpenRouterClient(config=config)
        result = client.chat("What is the policy?", context="Vacation policy: 15 days")
        assert result["success"] is False  # Will fail due to no API key, but tests the code path

    def test_chat_with_custom_model(self):
        """Test chat method with custom model"""
        config = OpenRouterConfig(api_key="")
        client = OpenRouterClient(config=config)
        result = client.chat("Hello", model="openai/gpt-4o")
        assert result["success"] is False  # Will fail due to no API key

    def test_system_prompt(self):
        """Test that system prompt is generated"""
        config = OpenRouterConfig(api_key="test")
        client = OpenRouterClient(config=config)
        prompt = client._system_prompt()
        assert isinstance(prompt, str)
        assert "DocuMind" in prompt
        assert "cite sources" in prompt.lower()

    def test_config_defaults(self):
        """Test OpenRouterConfig default values"""
        config = OpenRouterConfig(api_key="test-key")
        assert config.default_model == "anthropic/claude-3.5-sonnet"
        assert config.base_url == "https://openrouter.ai/api/v1"
        assert config.max_tokens == 4096
        assert config.temperature == 0.7

    def test_get_client(self):
        client = get_client()
        assert isinstance(client, OpenRouterClient)

    @patch("urllib.request.urlopen")
    def test_successful_chat_request(self, mock_urlopen):
        """Test successful API request"""
        # Mock successful API response
        mock_response = MagicMock()
        mock_response.read.return_value = b'{"choices": [{"message": {"content": "Test response"}}]}'
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response

        config = OpenRouterConfig(api_key="test-key")
        client = OpenRouterClient(config=config)
        result = client.chat("Hello")

        assert result["success"] is True
        assert result["content"] == "Test response"

    @patch("urllib.request.urlopen")
    def test_failed_chat_request(self, mock_urlopen):
        """Test failed API request"""
        # Mock failed API request
        mock_urlopen.side_effect = Exception("Network error")

        config = OpenRouterConfig(api_key="test-key")
        client = OpenRouterClient(config=config)
        result = client.chat("Hello")

        assert result["success"] is False
        assert "Network error" in result["error"]

    @patch("urllib.request.urlopen")
    def test_successful_chat_with_context(self, mock_urlopen):
        """Test successful API request with context"""
        # Mock successful API response
        mock_response = MagicMock()
        mock_response.read.return_value = b'{"choices": [{"message": {"content": "Answer based on context"}}]}'
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response

        config = OpenRouterConfig(api_key="test-key")
        client = OpenRouterClient(config=config)
        result = client.chat("What is the policy?", context="Vacation policy: 15 days PTO")

        assert result["success"] is True
        assert result["content"] == "Answer based on context"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
