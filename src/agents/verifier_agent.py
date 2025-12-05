"""
DocuMind Verifier Agent
Session 4: Verify document integrity and database operations
"""

from supabase import create_client, Client
import os
from typing import Dict, Any


class VerifierAgent:
    """Agent responsible for verifying document uploads and database integrity."""

    def __init__(self):
        supabase_url = os.getenv("SUPABASE_URL", "")
        supabase_key = os.getenv("SUPABASE_SERVICE_KEY", "")

        if not supabase_url or not supabase_key:
            raise ValueError("SUPABASE_URL and SUPABASE_SERVICE_KEY must be set")

        self.supabase: Client = create_client(supabase_url, supabase_key)

    def verify_document(self, document_id: str) -> Dict[str, Any]:
        """Verify a document exists and has valid data."""
        try:
            result = (
                self.supabase.table("documents")
                .select("*")
                .eq("id", document_id)
                .execute()
            )

            if not result.data:
                return {
                    "success": False,
                    "error": "Document not found"
                }

            doc = result.data[0]

            # Validation checks
            checks = {
                "has_title": bool(doc.get("title")),
                "has_content": bool(doc.get("content")),
                "has_file_type": bool(doc.get("file_type")),
                "content_not_empty": len(doc.get("content", "")) > 0,
                "has_metadata": doc.get("metadata") is not None
            }

            all_valid = all(checks.values())

            return {
                "success": True,
                "document_id": document_id,
                "valid": all_valid,
                "checks": checks,
                "document": doc
            }

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    def verify_database_connection(self) -> Dict[str, Any]:
        """Verify Supabase connection is working."""
        try:
            # Test connection with simple query
            result = self.supabase.table("documents").select("id").limit(1).execute()

            return {
                "success": True,
                "connected": True,
                "message": "Database connection verified"
            }

        except Exception as e:
            return {
                "success": False,
                "connected": False,
                "error": str(e)
            }

    def verify_schema(self) -> Dict[str, Any]:
        """Verify required database tables exist."""
        required_tables = ["documents", "document_chunks"]
        results = {}

        for table in required_tables:
            try:
                self.supabase.table(table).select("id").limit(1).execute()
                results[table] = True
            except Exception:
                results[table] = False

        all_exist = all(results.values())

        return {
            "success": all_exist,
            "tables": results,
            "message": "All tables exist" if all_exist else "Some tables missing"
        }


def create_verifier() -> VerifierAgent:
    """Factory function to create a verifier agent."""
    return VerifierAgent()
