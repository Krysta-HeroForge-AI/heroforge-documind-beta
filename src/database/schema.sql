-- DocuMind Database Schema
-- Session 4: Basic tables with vector support preparation

-- Enable pgvector extension for vector embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- Documents table: Store uploaded documents
CREATE TABLE IF NOT EXISTS documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    file_type TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Document chunks table: Store chunked content with embeddings (Session 5+)
CREATE TABLE IF NOT EXISTS document_chunks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    embedding vector(1536),  -- OpenAI embedding dimension
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast document lookup
CREATE INDEX IF NOT EXISTS idx_documents_created_at
    ON documents(created_at DESC);

-- Index for text search
CREATE INDEX IF NOT EXISTS idx_documents_title_gin
    ON documents USING gin(to_tsvector('english', title));

CREATE INDEX IF NOT EXISTS idx_documents_content_gin
    ON documents USING gin(to_tsvector('english', content));

-- Index for chunk lookup by document
CREATE INDEX IF NOT EXISTS idx_chunks_document_id
    ON document_chunks(document_id);

-- Vector index will be added in Session 8 for optimization
-- CREATE INDEX idx_chunks_embedding_hnsw
--     ON document_chunks USING hnsw (embedding vector_cosine_ops);

-- Row Level Security (RLS) - enable but allow all for now
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_chunks ENABLE ROW LEVEL SECURITY;

-- Allow all operations (adjust in production)
CREATE POLICY "Allow all operations on documents" ON documents
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on chunks" ON document_chunks
    FOR ALL USING (true) WITH CHECK (true);
