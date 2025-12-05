"""
DocuMind Custom MCP Server with FastMCP
Session 4: Database integration tools
"""

from fastmcp import FastMCP
from supabase import create_client, Client
import os
from typing import Optional, List, Dict, Any
from datetime import datetime

# Initialize FastMCP server
mcp = FastMCP("documind-mcp")

# Supabase client
supabase_url = os.getenv("SUPABASE_URL", "")
supabase_key = os.getenv("SUPABASE_SERVICE_KEY", "")
supabase: Optional[Client] = None

if supabase_url and supabase_key:
    supabase = create_client(supabase_url, supabase_key)


@mcp.tool()
def upload_document(
    title: str,
    content: str,
    file_type: str,
    metadata: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """Upload a document to DocuMind knowledge base."""
    if not supabase:
        return {"success": False, "error": "Supabase not configured"}

    try:
        doc_data = {
            "title": title,
            "content": content,
            "file_type": file_type,
            "metadata": metadata or {},
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        }

        result = supabase.table("documents").insert(doc_data).execute()

        return {
            "success": True,
            "document_id": result.data[0]["id"],
            "message": f"Uploaded: {title}"
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


@mcp.tool()
def search_documents(
    query: str,
    file_type: Optional[str] = None,
    limit: int = 10
) -> Dict[str, Any]:
    """Search documents by text query (simple text search for now)."""
    if not supabase:
        return {"success": False, "error": "Supabase not configured"}

    try:
        query_builder = supabase.table("documents").select("*")

        # Text search in title and content
        query_builder = query_builder.or_(f"title.ilike.%{query}%,content.ilike.%{query}%")

        if file_type:
            query_builder = query_builder.eq("file_type", file_type)

        query_builder = query_builder.limit(limit)
        result = query_builder.execute()

        return {
            "success": True,
            "count": len(result.data),
            "documents": result.data
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


@mcp.tool()
def list_documents(limit: int = 20, offset: int = 0) -> Dict[str, Any]:
    """List all documents in the knowledge base."""
    if not supabase:
        return {"success": False, "error": "Supabase not configured"}

    try:
        result = (
            supabase.table("documents")
            .select("id, title, file_type, created_at")
            .order("created_at", desc=True)
            .range(offset, offset + limit - 1)
            .execute()
        )

        return {
            "success": True,
            "count": len(result.data),
            "documents": result.data
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


@mcp.tool()
def get_document(document_id: str) -> Dict[str, Any]:
    """Retrieve a specific document by ID."""
    if not supabase:
        return {"success": False, "error": "Supabase not configured"}

    try:
        result = (
            supabase.table("documents")
            .select("*")
            .eq("id", document_id)
            .execute()
        )

        if not result.data:
            return {"success": False, "error": "Document not found"}

        return {
            "success": True,
            "document": result.data[0]
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


if __name__ == "__main__":
    # Run the MCP server
    mcp.run()
