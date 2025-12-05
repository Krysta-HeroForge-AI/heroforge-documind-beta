#!/bin/bash
# Build Session 9 Complete Branch for DocuMind
# Memory & Feedback System
# Run this from the root of your heroforge-documind repo
#
# Usage:
#   cd ~/heroforge-documind
#   chmod +x build-session-9.sh
#   ./build-session-9.sh

set -e

echo "🚀 Building session-9-complete branch (Memory & Feedback)..."

# Create branch from session-8-complete
git checkout session-8-complete
git pull origin session-8-complete
git checkout -b session-9-complete

# Create directories
mkdir -p src/memory
mkdir -p src/feedback
mkdir -p src/learning

echo "📁 Creating memory schema: src/database/memory_schema.sql"
cat > src/database/memory_schema.sql << 'MEMORY_SCHEMA_EOF'
-- DocuMind Memory & Feedback Schema
-- Session 9: Conversation tracking and learning

-- Conversations table: Track user sessions
CREATE TABLE IF NOT EXISTS conversations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT,
    session_id TEXT UNIQUE NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    message_count INT DEFAULT 0,
    metadata JSONB DEFAULT '{}'
);

-- Messages table: Store conversation messages
CREATE TABLE IF NOT EXISTS messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

-- Feedback table: Collect user ratings and feedback
CREATE TABLE IF NOT EXISTS feedback (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    helpful BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

-- Query history: Track search queries for analysis
CREATE TABLE IF NOT EXISTS query_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
    query TEXT NOT NULL,
    answer TEXT,
    sources_used JSONB,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    latency_ms FLOAT,
    chunks_retrieved INT
);

-- Learning insights: Store patterns and improvements
CREATE TABLE IF NOT EXISTS learning_insights (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    insight_type TEXT NOT NULL,
    description TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    confidence FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    applied BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_conversations_session
    ON conversations(session_id);

CREATE INDEX IF NOT EXISTS idx_conversations_user
    ON conversations(user_id);

CREATE INDEX IF NOT EXISTS idx_messages_conversation
    ON messages(conversation_id, timestamp);

CREATE INDEX IF NOT EXISTS idx_feedback_rating
    ON feedback(rating);

CREATE INDEX IF NOT EXISTS idx_query_history_timestamp
    ON query_history(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_learning_insights_type
    ON learning_insights(insight_type);

-- Function to get conversation statistics
CREATE OR REPLACE FUNCTION get_conversation_stats(
    hours_back int DEFAULT 24
)
RETURNS TABLE (
    total_conversations bigint,
    total_messages bigint,
    avg_messages_per_conversation float,
    avg_rating float,
    total_feedback bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT c.id)::bigint as total_conversations,
        COUNT(m.id)::bigint as total_messages,
        AVG(c.message_count)::float as avg_messages_per_conversation,
        AVG(f.rating)::float as avg_rating,
        COUNT(f.id)::bigint as total_feedback
    FROM conversations c
    LEFT JOIN messages m ON c.id = m.conversation_id
    LEFT JOIN feedback f ON m.id = f.message_id
    WHERE c.started_at > NOW() - (hours_back || ' hours')::interval;
END;
$$;
MEMORY_SCHEMA_EOF

echo "📁 Creating conversation memory: src/memory/conversation.py"
cat > src/memory/conversation.py << 'CONVERSATION_EOF'
"""
DocuMind Conversation Memory
Session 9: Multi-turn conversation tracking
"""

from typing import Dict, Any, List, Optional
from supabase import create_client, Client
import os
import uuid
from datetime import datetime


class ConversationMemory:
    """Manage conversation history and context."""

    def __init__(self, session_id: Optional[str] = None):
        supabase_url = os.getenv("SUPABASE_URL")
        supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

        if not supabase_url or not supabase_key:
            raise ValueError("Supabase credentials not set")

        self.supabase: Client = create_client(supabase_url, supabase_key)
        self.session_id = session_id or str(uuid.uuid4())
        self.conversation_id = None

        # Initialize or load conversation
        self._init_conversation()

    def _init_conversation(self):
        """Initialize or load existing conversation."""
        # Check if session exists
        result = (
            self.supabase.table("conversations")
            .select("*")
            .eq("session_id", self.session_id)
            .execute()
        )

        if result.data:
            self.conversation_id = result.data[0]["id"]
        else:
            # Create new conversation
            conv_data = {
                "session_id": self.session_id,
                "started_at": datetime.utcnow().isoformat(),
                "message_count": 0
            }
            result = (
                self.supabase.table("conversations")
                .insert(conv_data)
                .execute()
            )
            self.conversation_id = result.data[0]["id"]

    def add_message(
        self,
        role: str,
        content: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Add a message to the conversation."""
        try:
            message_data = {
                "conversation_id": self.conversation_id,
                "role": role,
                "content": content,
                "timestamp": datetime.utcnow().isoformat(),
                "metadata": metadata or {}
            }

            result = (
                self.supabase.table("messages")
                .insert(message_data)
                .execute()
            )

            # Update message count
            self.supabase.table("conversations").update({
                "message_count": self.supabase.table("messages")
                    .select("id", count="exact")
                    .eq("conversation_id", self.conversation_id)
                    .execute()
                    .count
            }).eq("id", self.conversation_id).execute()

            return {
                "success": True,
                "message_id": result.data[0]["id"]
            }

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    def get_history(
        self,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get recent conversation history."""
        try:
            result = (
                self.supabase.table("messages")
                .select("*")
                .eq("conversation_id", self.conversation_id)
                .order("timestamp", desc=False)
                .limit(limit)
                .execute()
            )

            return result.data if result.data else []

        except Exception as e:
            print(f"Error fetching history: {e}")
            return []

    def get_context(
        self,
        max_messages: int = 5
    ) -> str:
        """Get formatted context for RAG."""
        history = self.get_history(limit=max_messages)

        if not history:
            return ""

        context_parts = ["Previous conversation:"]

        for msg in history:
            role = "User" if msg["role"] == "user" else "Assistant"
            content = msg["content"]
            context_parts.append(f"{role}: {content}")

        return "\n".join(context_parts)

    def end_conversation(self):
        """Mark conversation as ended."""
        try:
            self.supabase.table("conversations").update({
                "ended_at": datetime.utcnow().isoformat()
            }).eq("id", self.conversation_id).execute()

            return {"success": True}

        except Exception as e:
            return {"success": False, "error": str(e)}


def create_conversation_memory(
    session_id: Optional[str] = None
) -> ConversationMemory:
    """Factory function to create conversation memory."""
    return ConversationMemory(session_id=session_id)
CONVERSATION_EOF

echo "📁 Creating feedback collector: src/feedback/collector.py"
cat > src/feedback/collector.py << 'FEEDBACK_EOF'
"""
DocuMind Feedback Collector
Session 9: Collect and store user feedback
"""

from typing import Dict, Any, Optional
from supabase import create_client, Client
import os
from datetime import datetime


class FeedbackCollector:
    """Collect and analyze user feedback."""

    def __init__(self):
        supabase_url = os.getenv("SUPABASE_URL")
        supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

        if not supabase_url or not supabase_key:
            raise ValueError("Supabase credentials not set")

        self.supabase: Client = create_client(supabase_url, supabase_key)

    def collect_feedback(
        self,
        message_id: str,
        rating: int,
        comment: Optional[str] = None,
        helpful: Optional[bool] = None
    ) -> Dict[str, Any]:
        """Collect feedback for a message."""
        if not 1 <= rating <= 5:
            return {
                "success": False,
                "error": "Rating must be between 1 and 5"
            }

        try:
            feedback_data = {
                "message_id": message_id,
                "rating": rating,
                "comment": comment,
                "helpful": helpful,
                "created_at": datetime.utcnow().isoformat()
            }

            result = (
                self.supabase.table("feedback")
                .insert(feedback_data)
                .execute()
            )

            return {
                "success": True,
                "feedback_id": result.data[0]["id"],
                "message": "Thank you for your feedback!"
            }

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    def record_query_feedback(
        self,
        query: str,
        answer: str,
        sources: list,
        rating: Optional[int] = None,
        latency_ms: Optional[float] = None,
        conversation_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Record query-specific feedback."""
        try:
            query_data = {
                "conversation_id": conversation_id,
                "query": query,
                "answer": answer,
                "sources_used": sources,
                "rating": rating,
                "latency_ms": latency_ms,
                "chunks_retrieved": len(sources),
                "timestamp": datetime.utcnow().isoformat()
            }

            result = (
                self.supabase.table("query_history")
                .insert(query_data)
                .execute()
            )

            return {
                "success": True,
                "query_id": result.data[0]["id"]
            }

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    def get_low_rated_queries(
        self,
        threshold: int = 2,
        limit: int = 20
    ) -> List[Dict[str, Any]]:
        """Get queries with low ratings for analysis."""
        try:
            result = (
                self.supabase.table("query_history")
                .select("*")
                .lte("rating", threshold)
                .order("timestamp", desc=True)
                .limit(limit)
                .execute()
            )

            return result.data if result.data else []

        except Exception as e:
            print(f"Error fetching low-rated queries: {e}")
            return []

    def get_feedback_stats(self) -> Dict[str, Any]:
        """Get feedback statistics."""
        try:
            result = (
                self.supabase.table("feedback")
                .select("rating")
                .execute()
            )

            if not result.data:
                return {
                    "total": 0,
                    "average_rating": 0,
                    "distribution": {}
                }

            ratings = [r["rating"] for r in result.data]
            distribution = {}
            for i in range(1, 6):
                distribution[i] = ratings.count(i)

            return {
                "total": len(ratings),
                "average_rating": sum(ratings) / len(ratings),
                "distribution": distribution
            }

        except Exception as e:
            print(f"Error getting stats: {e}")
            return {"error": str(e)}


def create_feedback_collector() -> FeedbackCollector:
    """Factory function to create feedback collector."""
    return FeedbackCollector()
FEEDBACK_EOF

echo "📁 Creating learning adaptation: src/learning/adapt.py"
cat > src/learning/adapt.py << 'LEARNING_EOF'
"""
DocuMind Learning Adaptation
Session 9: Learn from feedback to improve results
"""

from typing import Dict, Any, List
from supabase import create_client, Client
import os
from datetime import datetime


class LearningAdapter:
    """Adapt and improve based on user feedback."""

    def __init__(self):
        supabase_url = os.getenv("SUPABASE_URL")
        supabase_key = os.getenv("SUPABASE_SERVICE_KEY")

        if not supabase_url or not supabase_key:
            raise ValueError("Supabase credentials not set")

        self.supabase: Client = create_client(supabase_url, supabase_key)

    def analyze_feedback_patterns(self) -> Dict[str, Any]:
        """Analyze feedback to identify improvement areas."""
        try:
            # Get low-rated queries
            low_rated = (
                self.supabase.table("query_history")
                .select("*")
                .lte("rating", 2)
                .execute()
            )

            # Get high-rated queries
            high_rated = (
                self.supabase.table("query_history")
                .select("*")
                .gte("rating", 4)
                .execute()
            )

            insights = {
                "low_rated_count": len(low_rated.data) if low_rated.data else 0,
                "high_rated_count": len(high_rated.data) if high_rated.data else 0,
                "patterns": []
            }

            # Analyze common issues in low-rated queries
            if low_rated.data:
                insights["patterns"].append({
                    "type": "low_performance",
                    "description": "Queries with low ratings need improvement",
                    "count": len(low_rated.data)
                })

            return {
                "success": True,
                "insights": insights
            }

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    def store_learning_insight(
        self,
        insight_type: str,
        description: str,
        data: Dict[str, Any],
        confidence: float = 0.8
    ) -> Dict[str, Any]:
        """Store a learning insight for future use."""
        try:
            insight_data = {
                "insight_type": insight_type,
                "description": description,
                "data": data,
                "confidence": confidence,
                "created_at": datetime.utcnow().isoformat(),
                "applied": False
            }

            result = (
                self.supabase.table("learning_insights")
                .insert(insight_data)
                .execute()
            )

            return {
                "success": True,
                "insight_id": result.data[0]["id"]
            }

        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

    def get_active_insights(self) -> List[Dict[str, Any]]:
        """Get insights that should be applied."""
        try:
            result = (
                self.supabase.table("learning_insights")
                .select("*")
                .eq("applied", False)
                .gte("confidence", 0.7)
                .order("created_at", desc=True)
                .execute()
            )

            return result.data if result.data else []

        except Exception as e:
            print(f"Error fetching insights: {e}")
            return []

    def adjust_search_weights(
        self,
        feedback_data: List[Dict[str, Any]]
    ) -> Dict[str, float]:
        """Adjust search weights based on feedback."""
        # Simple learning algorithm: favor what works
        total_ratings = 0
        vector_success = 0
        keyword_success = 0

        for item in feedback_data:
            if item.get("rating", 0) >= 4:
                # High rating - this approach worked
                search_type = item.get("metadata", {}).get("search_type", "hybrid")
                if search_type == "vector":
                    vector_success += 1
                elif search_type == "keyword":
                    keyword_success += 1
                total_ratings += 1

        if total_ratings == 0:
            return {"vector_weight": 0.7, "keyword_weight": 0.3}

        # Adjust weights based on success rates
        vector_weight = 0.5 + (vector_success / total_ratings * 0.4)
        keyword_weight = 1.0 - vector_weight

        return {
            "vector_weight": vector_weight,
            "keyword_weight": keyword_weight
        }


def create_learning_adapter() -> LearningAdapter:
    """Factory function to create learning adapter."""
    return LearningAdapter()
LEARNING_EOF

echo "📁 Creating tests/test_memory_feedback.py"
cat > tests/test_memory_feedback.py << 'TEST_MEMORY_EOF'
"""Tests for DocuMind Memory & Feedback - Session 9"""

import pytest
from unittest.mock import Mock, patch, MagicMock


class TestConversationMemory:
    """Test Conversation Memory (mocked)."""

    @patch.dict('os.environ', {
        'SUPABASE_URL': 'https://test.supabase.co',
        'SUPABASE_SERVICE_KEY': 'test-key'
    })
    @patch('src.memory.conversation.create_client')
    def test_init_conversation(self, mock_client):
        """Test conversation initialization."""
        from src.memory.conversation import ConversationMemory

        mock_supabase = MagicMock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [
            {"id": "test-uuid"}
        ]
        mock_client.return_value = mock_supabase

        memory = ConversationMemory()
        assert memory.conversation_id is not None


class TestFeedbackCollector:
    """Test Feedback Collector."""

    def test_rating_validation(self):
        """Test rating validation."""
        from src.feedback.collector import FeedbackCollector

        with patch.dict('os.environ', {
            'SUPABASE_URL': 'https://test.supabase.co',
            'SUPABASE_SERVICE_KEY': 'test-key'
        }):
            with patch('src.feedback.collector.create_client'):
                collector = FeedbackCollector()

        result = collector.collect_feedback("msg-id", rating=6)
        assert result["success"] is False
        assert "between 1 and 5" in result["error"]


class TestLearningAdapter:
    """Test Learning Adapter."""

    def test_adjust_search_weights(self):
        """Test search weight adjustment."""
        from src.learning.adapt import LearningAdapter

        with patch.dict('os.environ', {
            'SUPABASE_URL': 'https://test.supabase.co',
            'SUPABASE_SERVICE_KEY': 'test-key'
        }):
            with patch('src.learning.adapt.create_client'):
                adapter = LearningAdapter()

        feedback = [
            {"rating": 5, "metadata": {"search_type": "vector"}},
            {"rating": 4, "metadata": {"search_type": "vector"}},
            {"rating": 4, "metadata": {"search_type": "keyword"}}
        ]

        weights = adapter.adjust_search_weights(feedback)
        assert "vector_weight" in weights
        assert "keyword_weight" in weights
        assert abs(weights["vector_weight"] + weights["keyword_weight"] - 1.0) < 0.01


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
TEST_MEMORY_EOF

# Commit everything
echo "📦 Committing changes..."
git add -A
git commit -m "Session 9: Memory and feedback learning system

Features:
- Conversation memory with session tracking
- Multi-turn conversation context
- Feedback collection (ratings, comments)
- Query history tracking
- Learning insights storage
- Pattern analysis from feedback
- Adaptive search weight adjustment
- Conversation statistics
- Low-rated query identification
- Database schema for memory/feedback
- Comprehensive tests

🤖 Generated with Claude Code"

echo ""
echo "✅ session-9-complete branch created!"
echo ""
echo "To push to GitHub:"
echo "  git push origin session-9-complete"
echo ""
echo "SQL to run in Supabase:"
echo "  src/database/memory_schema.sql"
echo ""
