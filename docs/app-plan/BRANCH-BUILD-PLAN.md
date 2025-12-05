# DocuMind Branch Build Plan

## Purpose

This document provides a step-by-step plan for pre-building DocuMind across 8 Git branches, one for each session (3-10). Each branch builds incrementally on the previous, culminating in a complete system that fulfills the PRD.

---

## Why Pre-Build Everything?

Based on complexity analysis:

| Session | Demo Time | Estimated Build Time | Gap |
|---------|-----------|---------------------|-----|
| S3 | 35 min | 110-220 min | **3-6x over** |
| S4 | 35 min | 100-200 min | **3-6x over** |
| S5 | 35 min | 110-220 min | **3-6x over** |
| S6 | 35 min | 82-164 min | **2-5x over** |
| S7 | 35 min | 84-168 min | **2-5x over** |
| S8 | 35 min | 62-124 min | **2-4x over** |
| S9 | 35 min | 58-116 min | **2-3x over** |
| S10 | 35 min | 82-164 min | **2-5x over** |

**Conclusion**: Live coding is impossible within time constraints. Pre-build everything.

---

## Repository Setup

**Target Repository**: `heroforge-documind` (student fork)

```bash
# Clone fresh copy for instructor builds
git clone https://github.com/mamd69/heroforge-documind instructor-documind
cd instructor-documind
```

---

## Branch Naming Convention

```
main                    → Empty starter (students fork this)
session-3-complete      → Skills, Subagents, Hooks
session-4-complete      → + Supabase, MCP
session-5-complete      → + Multi-Agent Pipeline
session-6-complete      → + RAG Q&A
session-7-complete      → + Advanced Parsing
session-8-complete      → + Vector Optimization
session-9-complete      → + Memory & Feedback
session-10-complete     → + Evaluation (FULL PRD)
```

---

## Session-by-Session Build Guide

### Session 3: Foundation (Skills, Subagents, Hooks)

**PRD Features to Implement**:
- Project structure and boilerplate
- Document upload Skill (basic file handling)
- Summarizer Subagent (extract key points)
- Auto-format Hook (markdown cleanup)
- OpenRouter configuration scaffold

**Branch Commands**:
```bash
git checkout main
git checkout -b session-3-complete
```

**What to Build**:

1. **Project Structure**
   ```
   documind/
   ├── .claude/
   │   ├── skills/
   │   │   └── document-processor.md
   │   ├── hooks/
   │   │   └── pre-commit-format.sh
   │   └── settings.json
   ├── src/
   │   └── utils/
   │       └── openrouter.py
   ├── docs/
   │   └── sample-doc.md
   ├── .env.example
   ├── requirements.txt
   └── README.md
   ```

2. **Custom Skill**: `document-processor.md`
   - YAML frontmatter with triggers
   - Process uploaded documents
   - Extract text and metadata
   - Return structured output

3. **Subagent**: Summarizer
   - Accept document content
   - Generate 3-5 bullet summary
   - Extract key entities

4. **Hook**: Auto-format
   - Pre-commit hook
   - Markdown formatting
   - Consistent style

5. **OpenRouter Scaffold**:
   - Basic client setup
   - Model configuration
   - API key handling

**Verification Checklist**:
- [ ] `/skill document-processor` works
- [ ] Subagent summarizes sample document
- [ ] Hook formats markdown on commit
- [ ] OpenRouter client initializes (even without key)

**Commit & Push**:
```bash
git add .
git commit -m "Session 3: Skills, Subagents, Hooks foundation"
git push origin session-3-complete
```

---

### Session 4: Database (MCP & Supabase)

**PRD Features to Implement**:
- Supabase project initialization
- Documents table schema
- Supabase MCP server integration
- Custom documind-mcp server (upload, search tools)
- Database read/write operations

**Branch Commands**:
```bash
git checkout session-3-complete
git checkout -b session-4-complete
```

**What to Build**:

1. **Supabase Setup**:
   - Create Supabase project (do this manually, document steps)
   - Enable pgvector extension
   - Create `documents` table
   - Create `document_chunks` table
   - Set up Row Level Security

2. **Database Schema** (from PRD):
   ```sql
   -- documents table
   -- document_chunks table with embedding vector(1536)
   -- HNSW index for vector search
   ```

3. **MCP Server**: `documind-mcp/`
   ```
   documind-mcp/
   ├── package.json
   ├── src/
   │   └── index.ts
   └── README.md
   ```
   - Tool: `upload_document`
   - Tool: `search_documents`
   - Tool: `list_documents`

4. **Integration**:
   - `.claude/settings.json` with MCP config
   - Supabase client in Python
   - Basic CRUD operations

**Verification Checklist**:
- [ ] Supabase tables created
- [ ] MCP server starts without errors
- [ ] Can upload document via MCP tool
- [ ] Can query documents via MCP tool
- [ ] Python client connects to Supabase

**Commit & Push**:
```bash
git add .
git commit -m "Session 4: Supabase database and MCP integration"
git push origin session-4-complete
```

---

### Session 5: Multi-Agent Processing (ClaudeFlow)

**PRD Features to Implement**:
- ClaudeFlow swarm initialization
- 4-agent processing pipeline (Extractor, Chunker, Embedder, Writer)
- Parallel batch processing
- Agent monitoring

**Branch Commands**:
```bash
git checkout session-4-complete
git checkout -b session-5-complete
```

**What to Build**:

1. **ClaudeFlow Setup**:
   ```bash
   npm install -g claude-flow@alpha
   ```

2. **Pipeline Script**: `src/pipeline/ingest.py`
   - Initialize swarm with mesh topology
   - Spawn 4 specialized agents
   - Coordinate document processing

3. **Agent Definitions**:
   - **Extractor**: Read file, extract raw text
   - **Chunker**: Split into 500-word chunks with overlap
   - **Embedder**: Generate embeddings via OpenAI
   - **Writer**: Store chunks in Supabase

4. **Batch Processing**:
   - Process 10+ documents simultaneously
   - Progress tracking
   - Error handling

**Verification Checklist**:
- [ ] Swarm initializes successfully
- [ ] Single document processes through pipeline
- [ ] 10 documents process in parallel
- [ ] Chunks appear in Supabase with embeddings

**Commit & Push**:
```bash
git add .
git commit -m "Session 5: Multi-agent document processing pipeline"
git push origin session-5-complete
```

---

### Session 6: RAG Q&A Implementation

**PRD Features to Implement**:
- Semantic search endpoint
- RAG pipeline (query → embed → search → generate → cite)
- Citation tracking
- CLI Q&A interface

**Branch Commands**:
```bash
git checkout session-5-complete
git checkout -b session-6-complete
```

**What to Build**:

1. **RAG Pipeline**: `src/rag/pipeline.py`
   - `embed_query()`: Generate query embedding
   - `search_similar()`: pgvector similarity search
   - `assemble_context()`: Build context from chunks
   - `generate_answer()`: Call OpenRouter with context
   - `extract_citations()`: Map sources to response

2. **CLI Interface**: `src/cli/ask.py`
   ```bash
   python -m documind.ask "What is our vacation policy?"
   ```
   - Display answer
   - Show source citations
   - Log query

3. **OpenRouter Integration**:
   - Model selection (Claude, GPT-4)
   - Prompt template
   - Response parsing

**Verification Checklist**:
- [ ] Can embed a query
- [ ] Vector search returns relevant chunks
- [ ] Answer generated with citations
- [ ] CLI works end-to-end

**Commit & Push**:
```bash
git add .
git commit -m "Session 6: RAG pipeline and Q&A interface"
git push origin session-6-complete
```

---

### Session 7: Advanced Document Parsing

**PRD Features to Implement**:
- Enhanced PDF extraction (tables, layouts)
- Word document parsing (DOCX)
- Spreadsheet support (XLSX)
- Metadata extraction
- Structure preservation

**Branch Commands**:
```bash
git checkout session-6-complete
git checkout -b session-7-complete
```

**What to Build**:

1. **PDF Parser**: `src/parsers/pdf.py`
   - PyPDF2 for simple PDFs
   - pdfplumber for tables
   - Layout detection
   - Header/footer removal

2. **DOCX Parser**: `src/parsers/docx.py`
   - python-docx extraction
   - Style preservation
   - Table handling

3. **XLSX Parser**: `src/parsers/xlsx.py`
   - pandas/openpyxl
   - Sheet iteration
   - Data type handling

4. **Unified Processor**: `src/parsers/processor.py`
   - File type detection
   - Route to appropriate parser
   - Consistent output format

**Verification Checklist**:
- [ ] Complex PDF extracts correctly
- [ ] DOCX preserves structure
- [ ] XLSX data readable
- [ ] Pipeline handles all formats

**Commit & Push**:
```bash
git add .
git commit -m "Session 7: Multi-format document parsing"
git push origin session-7-complete
```

---

### Session 8: Vector Search Optimization

**PRD Features to Implement**:
- pgvector extension optimization
- HNSW index tuning
- Batch embedding generation
- Hybrid search (semantic + keyword)
- Performance monitoring

**Branch Commands**:
```bash
git checkout session-7-complete
git checkout -b session-8-complete
```

**What to Build**:

1. **Index Optimization**:
   ```sql
   -- HNSW index with tuned parameters
   CREATE INDEX document_chunks_embedding_idx
   ON document_chunks
   USING hnsw (embedding vector_cosine_ops)
   WITH (m = 16, ef_construction = 64);
   ```

2. **Hybrid Search**: `src/search/hybrid.py`
   - Vector similarity score
   - Keyword (BM25-style) score
   - Combined ranking
   - Configurable weights

3. **Batch Embeddings**:
   - Process chunks in batches of 100
   - Rate limit handling
   - Progress tracking

4. **Performance Monitoring**:
   - Query latency logging
   - Search result quality metrics
   - Index stats dashboard

**Verification Checklist**:
- [ ] HNSW index created
- [ ] Hybrid search returns better results
- [ ] Batch embedding handles 1000+ chunks
- [ ] Search latency < 500ms

**Commit & Push**:
```bash
git add .
git commit -m "Session 8: Vector search optimization"
git push origin session-8-complete
```

---

### Session 9: Memory & Feedback System

**PRD Features to Implement**:
- Conversation memory (multi-turn Q&A)
- Feedback collection (1-5 stars + comments)
- Learning algorithm (adjust based on feedback)
- Personalized search
- Cross-session persistence

**Branch Commands**:
```bash
git checkout session-8-complete
git checkout -b session-9-complete
```

**What to Build**:

1. **Conversation Memory**: `src/memory/conversation.py`
   - `conversations` table
   - `messages` table
   - Context window management
   - Session persistence

2. **Feedback System**: `src/feedback/collector.py`
   - Rating collection (1-5)
   - Text feedback
   - Store with query context
   - Analytics queries

3. **Learning Algorithm**: `src/learning/adapt.py`
   - Analyze low-rated responses
   - Identify problematic chunks
   - Adjust retrieval weights
   - Prompt refinement

4. **Personalization**:
   - User history tracking
   - Preference learning
   - Result boosting

**Verification Checklist**:
- [ ] Multi-turn conversation works
- [ ] Feedback stored correctly
- [ ] Learning adjusts results
- [ ] Session persists across restarts

**Commit & Push**:
```bash
git add .
git commit -m "Session 9: Memory and feedback learning system"
git push origin session-9-complete
```

---

### Session 10: Evaluation & Quality (FULL PRD)

**PRD Features to Implement**:
- RAGAS evaluation suite
- Automated metrics (faithfulness, relevance, precision, recall)
- TruLens monitoring
- Multi-model comparison
- Production quality tracking

**Branch Commands**:
```bash
git checkout session-9-complete
git checkout -b session-10-complete
```

**What to Build**:

1. **RAGAS Integration**: `src/evaluation/ragas_eval.py`
   - Test dataset (20+ queries)
   - Faithfulness metric
   - Answer relevance metric
   - Context precision/recall

2. **TruLens Dashboard**: `src/evaluation/trulens_setup.py`
   - Initialize TruLens
   - Create feedback functions
   - Configure dashboard
   - Real-time monitoring

3. **Model Comparison**: `src/evaluation/compare_models.py`
   - Run same queries through Claude, GPT-4, Gemini
   - Compare metrics
   - Cost analysis
   - Recommendation engine

4. **Quality Gates**:
   - Minimum thresholds
   - Automated alerts
   - CI integration

**Verification Checklist**:
- [ ] RAGAS evaluation runs
- [ ] All metrics meet PRD targets:
  - Faithfulness > 0.90
  - Answer Relevance > 0.85
  - Context Precision > 0.80
  - Context Recall > 0.85
- [ ] TruLens dashboard accessible
- [ ] Model comparison working

**Commit & Push**:
```bash
git add .
git commit -m "Session 10: RAGAS evaluation and TruLens monitoring - FULL PRD"
git push origin session-10-complete
```

---

## PRD Coverage Matrix

| PRD Feature | Session | Branch |
|-------------|---------|--------|
| Project structure | 3 | session-3-complete |
| Document upload Skill | 3 | session-3-complete |
| Summarizer Subagent | 3 | session-3-complete |
| Auto-format Hook | 3 | session-3-complete |
| OpenRouter scaffold | 3 | session-3-complete |
| Supabase setup | 4 | session-4-complete |
| Documents table | 4 | session-4-complete |
| document_chunks table | 4 | session-4-complete |
| MCP integration | 4 | session-4-complete |
| Custom MCP server | 4 | session-4-complete |
| ClaudeFlow swarm | 5 | session-5-complete |
| Extractor agent | 5 | session-5-complete |
| Chunker agent | 5 | session-5-complete |
| Embedder agent | 5 | session-5-complete |
| Writer agent | 5 | session-5-complete |
| Parallel processing | 5 | session-5-complete |
| Semantic search | 6 | session-6-complete |
| RAG pipeline | 6 | session-6-complete |
| Answer generation | 6 | session-6-complete |
| Citation tracking | 6 | session-6-complete |
| CLI interface | 6 | session-6-complete |
| PDF parsing | 7 | session-7-complete |
| DOCX parsing | 7 | session-7-complete |
| XLSX parsing | 7 | session-7-complete |
| Metadata extraction | 7 | session-7-complete |
| HNSW index | 8 | session-8-complete |
| Hybrid search | 8 | session-8-complete |
| Batch embeddings | 8 | session-8-complete |
| Search monitoring | 8 | session-8-complete |
| Conversation memory | 9 | session-9-complete |
| Feedback collection | 9 | session-9-complete |
| Learning algorithm | 9 | session-9-complete |
| Personalization | 9 | session-9-complete |
| RAGAS evaluation | 10 | session-10-complete |
| TruLens monitoring | 10 | session-10-complete |
| Multi-model comparison | 10 | session-10-complete |
| Quality gates | 10 | session-10-complete |

**Coverage**: 100% of PRD features mapped to sessions

---

## Time Estimates for Pre-Building

| Session | Estimated Time | Complexity |
|---------|----------------|------------|
| S3 | 3-4 hours | Medium |
| S4 | 4-5 hours | High (Supabase setup) |
| S5 | 4-5 hours | High (ClaudeFlow) |
| S6 | 3-4 hours | Medium |
| S7 | 3-4 hours | Medium |
| S8 | 3-4 hours | High (pgvector) |
| S9 | 4-5 hours | Medium |
| S10 | 4-5 hours | High (RAGAS/TruLens) |

**Total**: 28-36 hours

**Recommendation**: Budget 1 week of focused work (4-5 hours/day)

---

## Demo Flow for Each Session

After pre-building, your demo becomes:

1. **Checkout branch** (30 seconds)
   ```bash
   git checkout session-X-complete
   ```

2. **Walk through code** (10-15 min)
   - Show file structure
   - Explain key components
   - Highlight design decisions

3. **Run live demo** (10-15 min)
   - Execute the working system
   - Show inputs and outputs
   - Demonstrate features

4. **Q&A and troubleshooting** (5-10 min)
   - Answer questions
   - Discuss common issues
   - Preview next session

**Total**: 30-35 minutes (within allocation)

---

## Next Steps

1. [ ] Create Supabase project (needed for S4+)
2. [ ] Fork heroforge-documind as instructor copy
3. [ ] Build Session 3 branch
4. [ ] Build Session 4 branch
5. [ ] Continue through Session 10
6. [ ] Test full demo flow for each session
7. [ ] Create troubleshooting notes

---

**Document Version**: 1.0
**Created**: 2025-12-01
**Purpose**: Guide instructor through pre-building all DocuMind branches
