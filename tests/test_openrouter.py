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
