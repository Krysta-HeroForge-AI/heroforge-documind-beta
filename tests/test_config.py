"""Tests for DocuMind Configuration - Session 3"""

import pytest
import os
from src.documind.config import get_env, validate_config, DEBUG, LOG_LEVEL


class TestConfig:
    def test_get_env_with_existing_var(self):
        """Test get_env with existing environment variable"""
        os.environ["TEST_VAR"] = "test_value"
        assert get_env("TEST_VAR") == "test_value"
        del os.environ["TEST_VAR"]

    def test_get_env_with_default(self):
        """Test get_env with default value"""
        result = get_env("NONEXISTENT_VAR", "default_value")
        assert result == "default_value"

    def test_get_env_without_default(self):
        """Test get_env without default returns None"""
        result = get_env("NONEXISTENT_VAR")
        assert result is None

    def test_validate_config_with_missing_key(self, capsys):
        """Test validate_config when ANTHROPIC_API_KEY is missing"""
        # Save original value
        original = os.environ.get("ANTHROPIC_API_KEY")

        # Remove the key
        if "ANTHROPIC_API_KEY" in os.environ:
            del os.environ["ANTHROPIC_API_KEY"]

        result = validate_config()
        captured = capsys.readouterr()

        assert result is False
        assert "Missing required environment variables" in captured.out
        assert "ANTHROPIC_API_KEY" in captured.out

        # Restore original value
        if original:
            os.environ["ANTHROPIC_API_KEY"] = original

    def test_validate_config_with_key_present(self):
        """Test validate_config when ANTHROPIC_API_KEY is present"""
        os.environ["ANTHROPIC_API_KEY"] = "test-key-123"
        result = validate_config()
        assert result is True
        del os.environ["ANTHROPIC_API_KEY"]

    def test_debug_setting(self):
        """Test DEBUG config parsing"""
        # DEBUG should be a boolean
        assert isinstance(DEBUG, bool)

    def test_log_level_default(self):
        """Test LOG_LEVEL has default"""
        assert LOG_LEVEL is not None
        assert isinstance(LOG_LEVEL, str)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
