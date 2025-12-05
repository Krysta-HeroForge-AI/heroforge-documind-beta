"""
DocuMind Uploader Agent
Session 4: Upload documents to Supabase
"""

from supabase import create_client, Client
import os
from typing import Dict, Any, Optional
from datetime import datetime
import hashlib


class UploaderAgent:
    """Agent responsible for uploading documents to Supabase."""

    def __init__(self):
        supabase_url = os.getenv("SUPABASE_URL", "")
        supabase_key = os.getenv("SUPABASE_SERVICE_KEY", "")

        if not supabase_url or not supabase_key:
            raise ValueError("SUPABASE_URL and SUPABASE_SERVICE_KEY must be set")

        self.supabase: Client = create_client(supabase_url, supabase_key)

    def upload_document(
        self,
        title: str,
        content: str,
        file_type: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Upload a document to Supabase."""
        try:
            # Generate content hash for deduplication
            content_hash = hashlib.md5(content.encode()).hexdigest()

            # Check if document already exists
            existing = (
                self.supabase.table("documents")
                .select("id")
                .eq("metadata->>content_hash", content_hash)
                .execute()
            )

            if existing.data:
                return {
                    "success": True,
                    "status": "duplicate",
                    "document_id": existing.data[0]["id"],
                    "message": f"Document already exists: {title}"
                }

            # Prepare document data
            doc_metadata = metadata or {}
            doc_metadata["content_hash"] = content_hash

            doc_data = {
                "title": title,
                "content": content,
                "file_type": file_type,
                "metadata": doc_metadata,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat()
            }

            # Insert document
            result = self.supabase.table("documents").insert(doc_data).execute()

            return {
                "success": True,
                "status": "uploaded",
                "document_id": result.data[0]["id"],
                "message": f"Successfully uploaded: {title}"
            }

        except Exception as e:
            return {
                "success": False,
                "status": "error",
                "error": str(e)
            }

    def upload_batch(self, documents: list) -> Dict[str, Any]:
        """Upload multiple documents in batch."""
        results = {
            "total": len(documents),
            "uploaded": 0,
            "duplicates": 0,
            "errors": 0,
            "details": []
        }

        for doc in documents:
            result = self.upload_document(
                title=doc["title"],
                content=doc["content"],
                file_type=doc["file_type"],
                metadata=doc.get("metadata")
            )

            if result["success"]:
                if result["status"] == "uploaded":
                    results["uploaded"] += 1
                elif result["status"] == "duplicate":
                    results["duplicates"] += 1
            else:
                results["errors"] += 1

            results["details"].append(result)

        return results


def create_uploader() -> UploaderAgent:
    """Factory function to create an uploader agent."""
    return UploaderAgent()
