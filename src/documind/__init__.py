"""
DocuMind - AI-Powered Knowledge Management System

Session 3: Skills, Subagents, Hooks (Foundation)
"""

__version__ = "0.3.0"
__author__ = "HeroForge Course Students"

from .config import validate_config, get_env
from .document_processor import DocumentProcessor, ProcessedDocument, process_document
from .openrouter import OpenRouterClient, get_client

__all__ = [
    "validate_config", "get_env",
    "DocumentProcessor", "ProcessedDocument", "process_document",
    "OpenRouterClient", "get_client",
]
