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
