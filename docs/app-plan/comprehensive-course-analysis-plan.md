# Comprehensive Course Analysis & Implementation Plan
## AI Software Development - DocuMind Course (Sessions 3-10)

**Document Purpose**: Strategic planning for course delivery optimization, including demo vs workshop comparison, Git branch strategy, PRD coverage analysis, and implementation roadmap.

**Created**: 2025-12-01
**Status**: Planning Phase
**Target Audience**: Course Instructor

---

## Executive Summary

This plan addresses four critical instructor needs:

1. **Visibility Problem**: Clear comparison of what's demonstrated vs what students build
2. **Time Management Problem**: Strategic approach to live demos vs pre-built examples
3. **Branch Strategy Problem**: Git workflow for presenting completed work while enabling student checkpoints
4. **Coverage Problem**: Verification that all PRD features are addressed across sessions 3-10

### Key Recommendations Preview

- **Pre-build Strategy**: Pre-build all major features with a show-and-explain approach
- **Branch Strategy**: Use `session-X-complete` branches for demos and `session-X-start` branches for student checkpoints
- **Time Allocation**: 15-20 min show/explain + 20-25 min student workshop time per session
- **Coverage Analysis**: Requires detailed extraction and mapping (see Section 4)

---

## Table of Contents

1. [Analysis Plan: Demos vs Workshops Comparison](#section-1)
2. [Branch Strategy: Git Workflow for Pre-Built Demos](#section-2)
3. [Gap Analysis: PRD Coverage Verification](#section-3)
4. [Implementation Roadmap: Concrete Next Steps](#section-4)

---

## Section 1: Analysis Plan - Demos vs Workshops Comparison {#section-1}

### 1.1 Current State Assessment

**Files to Analyze**:
- `/workspaces/course-ai-software-dev/docs/app/demo-instructions-all.md` (9,568 lines)
- `/workspaces/course-ai-software-dev/docs/app/workshops-all.md` (40,748 lines)
- `/workspaces/course-ai-software-dev/docs/documind/documind-prd.md` (702 lines)

**Document Structure Discovery**:

Demo Instructions (sessions 3-10):
```
Line 12:    Session 3 Demo
Line 1110:  Session 4 Demo
Line 2166:  Session 5 Demo
Line 3248:  Session 6 Demo
Line 4293:  Session 7 Demo
Line 5523:  Session 8 Demo
Line 6758:  Session 9 Demo
Line 8360:  Session 10 Demo
```

Workshop Instructions (more complex - includes setup guides, speaker scripts):
```
Session 3: Multiple sections (Demo copy, Setup Guide, Advanced Features, Workshop)
Session 4: Demo copy, MCP guide, Workshop
Session 5: Demo copy, Multi-Agent guides, Workshop
Session 6: Demo copy, RAG guides, Workshop
Session 7: Demo copy, Data Extraction guides, Workshop
Session 8: Demo copy, Vector DB guides, Workshop
Session 9: Demo copy, Memory guides, Workshop
Session 10: Demo copy, Evaluation guides, Workshop
```

### 1.2 Extraction Strategy

**Phase 1: Automated Extraction**

Create a parser script to extract:
- Demo section headers and key activities
- Workshop section headers and key activities
- Time allocations for each
- Technical components built in each

**Recommended Approach**:
```python
# Script: extract_session_comparison.py
# Purpose: Parse both files and create structured comparison

import re
from typing import Dict, List

def extract_session_content(file_path: str, session_num: int) -> Dict:
    """Extract all content for a specific session"""
    # Parse markdown sections
    # Extract: objectives, activities, code examples, time estimates
    pass

def compare_demo_vs_workshop(session_num: int) -> Dict:
    """Compare what instructor shows vs what students build"""
    demo_content = extract_session_content("demo-instructions-all.md", session_num)
    workshop_content = extract_session_content("workshops-all.md", session_num)

    return {
        "session": session_num,
        "demo_activities": demo_content["activities"],
        "workshop_activities": workshop_content["activities"],
        "demo_components": demo_content["components"],
        "workshop_components": workshop_content["components"],
        "overlap": find_overlap(demo_content, workshop_content),
        "differences": find_differences(demo_content, workshop_content)
    }
```

**Phase 2: Manual Review**

For each session, manually verify:
- What code is written in demos
- What code is written in workshops
- Whether workshop builds on demo or repeats it
- Whether students get starting code or build from scratch

### 1.3 Comparison Framework

**Output Format**: Create a comparison table for each session

```markdown
## Session X Comparison

| Aspect | Demo (Instructor Shows) | Workshop (Students Build) | Overlap/Difference |
|--------|------------------------|---------------------------|-------------------|
| **Time Allocated** | XX minutes | XX minutes | - |
| **Primary Focus** | [Topic] | [Topic] | [Same/Different] |
| **Code Written** | [Files/Components] | [Files/Components] | [% Overlap] |
| **Starting Point** | From scratch / Checkpoint | From demo / From scratch | - |
| **Deliverables** | [What's created] | [What's created] | [Comparison] |
| **PRD Features** | [Which features] | [Which features] | [Mapping] |
| **Complexity Level** | Basic/Intermediate/Advanced | Basic/Intermediate/Advanced | - |
```

### 1.4 Key Questions to Answer

For each session 3-10:

1. **Duplication Check**: Do students rebuild what instructor just showed, or do they extend it?
2. **Starting Point**: Do students start from the completed demo code, or from a different checkpoint?
3. **Scope Difference**: Is the workshop a simpler version, an extension, or completely different?
4. **Time Feasibility**: Can students realistically complete the workshop in allocated time?
5. **Incremental Build**: Does each workshop build on the previous session's work?

### 1.5 Analysis Outputs

**Deliverable 1**: Session-by-Session Comparison Table (8 sessions × detailed table)

**Deliverable 2**: Aggregated Insights
- Total instructor demo time vs student workshop time
- Percentage of overlapping content
- Identification of redundant demonstrations
- Recommendations for consolidation

**Deliverable 3**: Visibility Dashboard (suggested format)
```
Session 3: Skills, Subagents, Hooks
├── Demo: Creates document-processor Skill, summarizer Subagent, auto-format Hook
├── Workshop: Students create their own Skill/Subagent/Hook (different from demo)
├── Overlap: 0% (different examples)
├── PRD Coverage: Foundation setup (not specific features)
└── Recommendation: Keep separate - good learning approach

Session 4: MCP & Supabase
├── Demo: Supabase setup, documind-mcp server, database CRUD
├── Workshop: Students connect their own Supabase, test MCP tools
├── Overlap: 80% (same activities, students follow along)
├── PRD Coverage: Documents table, basic storage
└── Recommendation: Consider pre-building, focus on troubleshooting
```

---

## Section 2: Branch Strategy - Git Workflow for Pre-Built Demos {#section-2}

### 2.1 Problem Statement

**Current Challenge**:
- If building live during demo, Claude Code response time creates dead air
- If pre-building everything, need a way to show completed state while enabling student checkpoints
- Need to demonstrate incremental progress across 8 sessions

**Constraints**:
- Students work in their own forks of `heroforge-documind`
- Each session builds on the previous session's work
- Instructor needs to show "completed" state for current session
- Students need "starting point" for workshop (may include previous session's completions)

### 2.2 Recommended Branch Strategy

**Branch Naming Convention**:

```
main
├── session-3-start      (Empty DocuMind foundation)
├── session-3-complete   (Skills, Subagents, Hooks implemented)
├── session-4-start      (= session-3-complete, ready for MCP work)
├── session-4-complete   (Supabase + MCP integrated)
├── session-5-start      (= session-4-complete, ready for multi-agent)
├── session-5-complete   (ClaudeFlow swarm + document processing)
├── session-6-start      (= session-5-complete, ready for RAG)
├── session-6-complete   (RAG pipeline + Q&A interface)
├── session-7-start      (= session-6-complete, ready for advanced parsing)
├── session-7-complete   (PDF/DOCX/XLSX parsers)
├── session-8-start      (= session-7-complete, ready for vector search)
├── session-8-complete   (pgvector + optimized search)
├── session-9-start      (= session-8-complete, ready for memory)
├── session-9-complete   (Memory + feedback system)
├── session-10-start     (= session-9-complete, ready for evaluation)
└── session-10-complete  (RAGAS + TruLens + full system)
```

**Key Principles**:
1. Each `session-X-complete` = instructor's finished demo
2. Each `session-X-start` = student's checkpoint to begin workshop
3. `session-(X+1)-start` often equals `session-X-complete` (students build on previous work)

### 2.3 Workflow for Instructor

**Before Each Session**:

```bash
# Example: Preparing for Session 5

# 1. Checkout the starting point
git checkout session-4-complete
git checkout -b session-5-complete

# 2. Pre-build the session 5 features
# (Use Claude Code to build multi-agent processing pipeline)
dsp
# ... build features ...
exit

# 3. Commit completed work
git add .
git commit -m "feat(session-5): implement multi-agent document processing pipeline

- Add ClaudeFlow swarm initialization
- Create 4-agent pipeline (extractor, chunker, embedder, writer)
- Implement parallel batch processing
- Add agent monitoring dashboard

Closes #session-5"

# 4. Push completed branch
git push origin session-5-complete

# 5. Create student starting point (usually same as this completion)
git checkout -b session-5-start session-4-complete
git push origin session-5-start

# 6. Tag for easy reference
git tag -a "s5-demo" -m "Session 5 Demo: Multi-Agent Processing"
git push origin s5-demo
```

**During Live Demo**:

```bash
# Option A: Show-and-Explain Approach (RECOMMENDED)
# Checkout pre-built completed branch
git checkout session-5-complete

# Walk through the code, explaining:
# - Why design decisions were made
# - How components interact
# - Key code sections and patterns
# - Common pitfalls and solutions

# Run the working system
npm run demo-session-5

# Show students the results without building live


# Option B: Selective Live Coding (if time permits)
# Checkout starting point
git checkout session-5-start

# Live-code ONE focused example (e.g., the extractor agent)
# Then switch to completed version for the rest
git checkout session-5-complete
```

**For Student Workshops**:

Students always start from `session-X-start`:

```bash
# Student workflow
git checkout session-X-start
git checkout -b my-session-X-work

# ... build workshop features ...

git commit -m "workshop(session-X): completed workshop exercises"
```

### 2.4 Branch Protection & Maintenance

**Protected Branches**:
- `main` - production-ready complete system
- `session-*-complete` - instructor demo branches (read-only for students)
- `session-*-start` - student checkpoint branches

**Branch Descriptions**:

Add descriptions to GitHub branches:
```bash
git branch --edit-description session-5-complete
# Description: "Instructor demo for Session 5 - Multi-Agent Processing.
# Includes ClaudeFlow swarm, 4-agent pipeline, parallel processing.
# DO NOT MODIFY - for reference only."
```

### 2.5 Alternative: Tag-Based Strategy

**If branches become unwieldy**, use tags instead:

```bash
# Tag completed states
git tag -a "session-3-complete" -m "Session 3 complete: Skills, Subagents, Hooks"
git tag -a "session-4-complete" -m "Session 4 complete: MCP & Supabase"
# ... etc

# Push tags
git push origin --tags

# Students/instructor can checkout specific states
git checkout session-5-complete
```

**Pros of tags**: Less branch clutter, clearer "points in time"
**Cons of tags**: Can't easily update if fixes needed

### 2.6 Documentation Strategy

**Create `/docs/instructor/branch-guide.md`**:

```markdown
# Instructor Branch Guide

## Quick Reference

| Session | Topic | Complete Branch | Start Branch | Key Features |
|---------|-------|-----------------|--------------|--------------|
| 3 | Skills/Subagents/Hooks | session-3-complete | session-3-start | document-processor Skill, summarizer Subagent, auto-format Hook |
| 4 | MCP & Supabase | session-4-complete | session-4-start | Supabase integration, documind-mcp server, CRUD operations |
| 5 | Multi-Agent | session-5-complete | session-5-start | ClaudeFlow swarm, 4-agent pipeline, parallel processing |
| ... | ... | ... | ... | ... |

## How to Use

### For Demos
1. Checkout `session-X-complete`
2. Run `npm run demo-session-X`
3. Walk through code, explain design decisions
4. Show working system

### For Student Workshops
1. Direct students to `session-X-start`
2. Students create feature branches from there
3. Workshop instructions in `/docs/workshops/session-X-workshop.md`
```

### 2.7 CI/CD Integration

**Automated Testing Per Branch**:

```yaml
# .github/workflows/session-demos.yml
name: Session Demo Validation

on:
  push:
    branches:
      - 'session-*-complete'

jobs:
  validate-demo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Extract session number
        run: echo "SESSION=$(echo ${{ github.ref_name }} | grep -oP 'session-\K\d+')" >> $GITHUB_ENV
      - name: Run session-specific tests
        run: npm run test:session-${{ env.SESSION }}
      - name: Verify all dependencies work
        run: npm run validate-session-${{ env.SESSION }}
```

This ensures each completed demo branch is functional before students access it.

---

## Section 3: Gap Analysis - PRD Coverage Verification {#section-3}

### 3.1 PRD Feature Inventory

**From `/docs/documind/documind-prd.md`**, DocuMind must include:

**Core Features** (from PRD Section "Key Features"):
1. Natural Language Q&A Interface
2. Source Attribution and Citations
3. Multi-Format Document Support (PDF, DOCX, XLSX, Markdown, HTML)
4. Intelligent Semantic Search
5. Learning from User Feedback
6. Multi-Model Flexibility via OpenRouter
7. Quality Evaluation and Monitoring
8. Multi-Agent Document Processing

**Architecture Components** (from PRD Architecture section):
1. Chatbot Interface (CLI/Web)
2. RAG Pipeline (6 sub-steps)
3. Document Processing Pipeline (4 agents)
4. Supabase (PostgreSQL + pgvector)
5. OpenRouter (multi-model LLM gateway)
6. Memory & Learning System
7. Evaluation & Monitoring (RAGAS, TruLens)

**Database Schema** (from PRD Technical Specifications):
- `documents` table
- `document_chunks` table (with vector embeddings)
- `conversations` table
- `messages` table
- `query_feedback` table
- `evaluation_runs` table

### 3.2 Session-to-PRD Mapping Framework

**From PRD Section "Feature Roadmap"**, expected session coverage:

| Session | PRD Features Expected | Database Components | Key Capabilities |
|---------|----------------------|---------------------|------------------|
| **3** | Foundation setup | None yet | Skills, Subagents, Hooks, OpenRouter config |
| **4** | Document storage | `documents` table | Supabase connection, MCP integration, CRUD operations |
| **5** | Multi-agent processing | `document_chunks` table | 4-agent pipeline, parallel processing, embeddings |
| **6** | RAG Q&A | `conversations`, `messages` | Semantic search, answer generation, citations |
| **7** | Multi-format parsing | Enhanced metadata in `documents` | PDF/DOCX/XLSX parsers, structure preservation |
| **8** | Semantic search optimization | `document_chunks` with vector index | pgvector, HNSW index, hybrid search |
| **9** | Memory & learning | `query_feedback` table | Conversation memory, feedback system, personalization |
| **10** | Quality assurance | `evaluation_runs` table | RAGAS metrics, TruLens monitoring, multi-model comparison |

### 3.3 Gap Analysis Methodology

**Step 1: Extract Actual Coverage from Demo/Workshop Files**

For each session, extract:
- What features are actually built in demos
- What features are actually built in workshops
- What database tables/schemas are created
- What API integrations are implemented

**Step 2: Compare Against PRD**

Create a checklist:

```markdown
## Session 3 Coverage Analysis

### PRD Expected (from Feature Roadmap):
- [x] Project structure and boilerplate
- [x] Document upload Skill (basic file handling)
- [x] Summarizer Subagent (extract key points)
- [x] Auto-format Hook (markdown cleanup)
- [x] OpenRouter configuration scaffold

### Actually Built in Demo:
- [x] document-processor Skill
- [x] summarizer Subagent
- [x] auto-format Hook
- [ ] OpenRouter configuration (is this included?)

### Actually Built in Workshop:
- [x] Students create custom Skill
- [x] Students create custom Subagent
- [x] Students create custom Hook
- [ ] OpenRouter testing (needs verification)

### Gap Assessment:
- ✅ COVERED: Core Skills/Subagents/Hooks concepts
- ⚠️ PARTIAL: OpenRouter config mentioned but not fully implemented
- ✅ APPROPRIATE: Foundation-only, no specific DocuMind features yet

### Recommendation:
Session 3 appropriately focuses on Claude Code capabilities, not DocuMind features.
OpenRouter config should be verified - if missing, add to Session 4 or 6.
```

**Repeat for Sessions 4-10**.

### 3.4 Gap Identification Matrix

**Create a comprehensive matrix**:

```markdown
| PRD Feature | Expected Session | Demo Coverage | Workshop Coverage | Status |
|-------------|------------------|---------------|-------------------|--------|
| **Natural Language Q&A** | Session 6 | [Yes/No/Partial] | [Yes/No/Partial] | ✅/⚠️/❌ |
| - Query embedding | Session 6 | [Status] | [Status] | [Icon] |
| - Semantic search | Session 6 | [Status] | [Status] | [Icon] |
| - Answer generation | Session 6 | [Status] | [Status] | [Icon] |
| - Citation extraction | Session 6 | [Status] | [Status] | [Icon] |
| **Source Attribution** | Session 6 | [Status] | [Status] | [Icon] |
| **Multi-Format Documents** | Session 7 | [Status] | [Status] | [Icon] |
| - PDF simple extraction | Session 5? | [Status] | [Status] | [Icon] |
| - PDF complex (tables) | Session 7 | [Status] | [Status] | [Icon] |
| - DOCX parsing | Session 7 | [Status] | [Status] | [Icon] |
| - XLSX parsing | Session 7 | [Status] | [Status] | [Icon] |
| **Semantic Search** | Session 8 | [Status] | [Status] | [Icon] |
| - pgvector setup | Session 8 | [Status] | [Status] | [Icon] |
| - HNSW indexing | Session 8 | [Status] | [Status] | [Icon] |
| - Hybrid search | Session 8 | [Status] | [Status] | [Icon] |
| **User Feedback** | Session 9 | [Status] | [Status] | [Icon] |
| - Rating system | Session 9 | [Status] | [Status] | [Icon] |
| - Feedback storage | Session 9 | [Status] | [Status] | [Icon] |
| - Learning algorithm | Session 9 | [Status] | [Status] | [Icon] |
| **Multi-Model Flexibility** | Session 6 | [Status] | [Status] | [Icon] |
| - OpenRouter integration | Session 6 | [Status] | [Status] | [Icon] |
| - Model selection | Session 10? | [Status] | [Status] | [Icon] |
| - A/B testing | Session 10? | [Status] | [Status] | [Icon] |
| **Quality Evaluation** | Session 10 | [Status] | [Status] | [Icon] |
| - RAGAS integration | Session 10 | [Status] | [Status] | [Icon] |
| - TruLens monitoring | Session 10 | [Status] | [Status] | [Icon] |
| - Multi-model comparison | Session 10 | [Status] | [Status] | [Icon] |
| **Multi-Agent Processing** | Session 5 | [Status] | [Status] | [Icon] |
| - ClaudeFlow swarm | Session 5 | [Status] | [Status] | [Icon] |
| - 4-agent pipeline | Session 5 | [Status] | [Status] | [Icon] |
| - Parallel processing | Session 5 | [Status] | [Status] | [Icon] |
```

**Icons**:
- ✅ Fully Covered
- ⚠️ Partially Covered
- ❌ Not Covered (gap identified)
- 🔄 Covered in different session than PRD specified
- ❓ Needs verification (unclear from documents)

### 3.5 Critical Gaps to Identify

**Common gaps to watch for**:

1. **Database Schema Completeness**
   - Are all 6 tables from PRD implemented?
   - Are vector indexes actually created?
   - Are table relationships properly defined?

2. **RAG Pipeline Completeness**
   - All 6 steps implemented? (query understanding, semantic search, ranking, context assembly, answer generation, citation extraction)
   - End-to-end working flow?

3. **Multi-Format Support**
   - All formats listed in PRD supported? (PDF, DOCX, XLSX, Markdown, HTML)
   - Complex PDF parsing (tables, layouts)?

4. **Memory & Learning**
   - Multi-turn conversations?
   - Cross-session persistence?
   - Actual learning algorithm or just feedback collection?

5. **Evaluation**
   - All RAGAS metrics implemented? (faithfulness, relevance, precision, recall)
   - TruLens actually integrated or just mentioned?
   - Automated evaluation on deploy?

6. **User Stories Fulfillment**
   - Can users actually ask questions and get cited answers?
   - Can admins actually manage documents?
   - Do analytics exist?

### 3.6 Gap Analysis Output

**Deliverable**: Gap Analysis Report

```markdown
# DocuMind PRD Coverage - Gap Analysis Report

## Summary Statistics
- Total PRD Features: [X]
- Fully Covered: [X] (XX%)
- Partially Covered: [X] (XX%)
- Not Covered: [X] (XX%)
- Coverage by Session: [breakdown]

## Critical Gaps Identified

### Gap 1: [Feature Name]
**PRD Requirement**: [Description from PRD]
**Expected Session**: Session X
**Current Status**: Not covered / Partially covered
**Impact**: [Why this matters]
**Recommendation**: [How to address]

### Gap 2: [Feature Name]
...

## Recommendations

### High Priority (must add)
1. [Gap/feature to add]
2. [Gap/feature to add]

### Medium Priority (should add)
1. [Gap/feature to enhance]

### Low Priority (nice to have)
1. [Gap/feature to consider]

## Sessions Needing Revision
- **Session X**: Add [features]
- **Session Y**: Expand [components]
```

---

## Section 4: Implementation Roadmap - Concrete Next Steps {#section-4}

### 4.1 Immediate Actions (This Week)

**Priority 1: Complete the Analysis (Est. 4-6 hours)**

Use GOAP-style systematic extraction:

```bash
# Step 1: Extract session summaries (automated)
python scripts/extract_session_comparison.py \
  --demo-file docs/app/demo-instructions-all.md \
  --workshop-file docs/app/workshops-all.md \
  --output docs/analysis/session-comparison-raw.json

# Step 2: Extract PRD features (automated)
python scripts/extract_prd_features.py \
  --prd-file docs/documind/documind-prd.md \
  --output docs/analysis/prd-features.json

# Step 3: Generate comparison reports (automated + manual review)
python scripts/generate_comparison_report.py \
  --sessions docs/analysis/session-comparison-raw.json \
  --prd docs/analysis/prd-features.json \
  --output docs/analysis/

# Manual review required after automated extraction
```

**Scripts to create**:
1. `scripts/extract_session_comparison.py` - Parse markdown, extract structured data
2. `scripts/extract_prd_features.py` - Parse PRD into feature checklist
3. `scripts/generate_comparison_report.py` - Create comparison tables and gap analysis

**Expected Outputs**:
- `docs/analysis/session-comparison-summary.md` - High-level overview
- `docs/analysis/session-by-session-details.md` - Detailed per-session breakdown
- `docs/analysis/prd-coverage-matrix.md` - Feature coverage matrix
- `docs/analysis/gap-analysis-report.md` - Identified gaps and recommendations

**Priority 2: Create Branch Strategy Document (Est. 1-2 hours)**

```bash
# Create comprehensive branch guide
cat > docs/instructor/branch-strategy.md << 'EOF'
[Content from Section 2 of this document]
EOF

# Document current state
git branch -a > docs/instructor/current-branches.txt
git log --oneline --graph --all > docs/instructor/current-history.txt
```

**Priority 3: Decision on Pre-Building (Est. 30 min)**

Based on analysis results, decide:

- [ ] **Option A**: Pre-build all sessions 3-10 now (bulk approach)
- [ ] **Option B**: Pre-build incrementally before each session
- [ ] **Option C**: Hybrid (pre-build sessions 4-8, live-code sessions 3, 9-10)

**Recommendation**: Option B (incremental) allows you to adjust based on student feedback and ensures you understand each session deeply before teaching it.

### 4.2 Short-Term Actions (Next 2 Weeks)

**Week 1: Analysis & Planning**

Monday-Tuesday:
- [ ] Run automated extraction scripts
- [ ] Manually review extraction accuracy
- [ ] Complete session-by-session comparison tables
- [ ] Identify immediate gaps in sessions 3-5 (upcoming sessions)

Wednesday-Thursday:
- [ ] Complete PRD coverage matrix
- [ ] Write gap analysis report
- [ ] Prioritize gaps (must-fix vs nice-to-have)
- [ ] Create session revision plan

Friday:
- [ ] Document branch strategy
- [ ] Set up protected branches in heroforge-documind repo
- [ ] Create branch description templates
- [ ] Test checkout/demo workflow

**Week 2: Implementation & Testing**

Monday-Wednesday (focus on Session 3-5):
- [ ] Pre-build Session 3 complete state
- [ ] Create `session-3-complete` branch
- [ ] Test demo flow (show-and-explain)
- [ ] Verify student starting point (`session-3-start`)
- [ ] Repeat for Sessions 4-5

Thursday:
- [ ] Run through demo simulation (record yourself)
- [ ] Time each section (ensure fits in allotted time)
- [ ] Identify talking points for show-and-explain
- [ ] Prepare troubleshooting Q&A

Friday:
- [ ] Address any identified gaps in Sessions 3-5
- [ ] Update demo instructions if needed
- [ ] Update workshop instructions if needed
- [ ] Create instructor notes document

### 4.3 Medium-Term Actions (Next Month)

**Sessions 6-8 (Weeks 3-4)**:
- [ ] Pre-build Session 6 (RAG implementation)
- [ ] Pre-build Session 7 (Advanced parsing)
- [ ] Pre-build Session 8 (Vector optimization)
- [ ] Create complete branches for each
- [ ] Document design decisions and common issues
- [ ] Prepare show-and-explain scripts

**Sessions 9-10 (Week 4)**:
- [ ] Pre-build Session 9 (Memory & feedback)
- [ ] Pre-build Session 10 (Evaluation & monitoring)
- [ ] Complete all branches
- [ ] Final PRD coverage verification
- [ ] Create "full system demo" for Session 10

**Testing & Validation**:
- [ ] Run through entire 8-session arc
- [ ] Verify each session builds on previous
- [ ] Test all branches checkout correctly
- [ ] Ensure no broken dependencies
- [ ] Document known issues and workarounds

### 4.4 Long-Term Actions (Ongoing)

**Continuous Improvement**:

After Each Session:
- [ ] Collect student feedback on workshop difficulty
- [ ] Note timing issues (too fast/slow)
- [ ] Identify confusing concepts
- [ ] Update demo/workshop docs based on real experience
- [ ] Adjust next session's plan accordingly

After Course Completion:
- [ ] Comprehensive review of all sessions
- [ ] Update PRD with "as-built" documentation
- [ ] Create "lessons learned" document
- [ ] Prepare materials for next cohort
- [ ] Consider creating video walkthroughs for each branch

### 4.5 Detailed Task Breakdown (First Week)

**Day 1: Extraction & Parsing**

Morning (3 hours):
```bash
# 1. Create extraction script directory
mkdir -p scripts/analysis

# 2. Create first extraction script
cat > scripts/analysis/extract_sessions.py << 'EOF'
#!/usr/bin/env python3
"""
Extract session content from demo and workshop markdown files.
Generates structured JSON for comparison.
"""
import re
import json
from pathlib import Path
from typing import Dict, List, Optional

# [Implementation details]
EOF

chmod +x scripts/analysis/extract_sessions.py

# 3. Run extraction
python3 scripts/analysis/extract_sessions.py

# 4. Review JSON output
code docs/analysis/session-comparison-raw.json
```

Afternoon (3 hours):
```bash
# 5. Create PRD extraction script
cat > scripts/analysis/extract_prd.py << 'EOF'
#!/usr/bin/env python3
"""
Extract features and requirements from PRD markdown.
Generates structured JSON for gap analysis.
"""
# [Implementation details]
EOF

# 6. Run PRD extraction
python3 scripts/analysis/extract_prd.py

# 7. Manual review and corrections
code docs/analysis/prd-features.json
```

**Day 2: Comparison Generation**

Morning (3 hours):
```bash
# 8. Create comparison generator
cat > scripts/analysis/generate_comparison.py << 'EOF'
#!/usr/bin/env python3
"""
Generate comparison tables and gap analysis reports.
"""
# [Implementation details]
EOF

# 9. Run comparison generation
python3 scripts/analysis/generate_comparison.py

# 10. Review generated reports
code docs/analysis/
```

Afternoon (3 hours):
- [ ] Manual review of all generated reports
- [ ] Add commentary and insights
- [ ] Identify obvious gaps
- [ ] Create summary slides for yourself

**Day 3: Branch Strategy**

Morning (2 hours):
```bash
# 11. Document current Git state
cd /path/to/heroforge-documind
git branch -a > ../course-repo/docs/instructor/git-current-state.txt
git log --oneline --graph --decorate --all > ../course-repo/docs/instructor/git-history.txt

# 12. Create branch strategy document
cd ../course-repo
cat > docs/instructor/branch-strategy.md << 'EOF'
[Content from Section 2 of this planning document]
EOF
```

Afternoon (2 hours):
```bash
# 13. Test branch workflow with Session 3
cd /path/to/heroforge-documind

# Create test branches
git checkout -b session-3-complete-test
# ... make some sample changes ...
git commit -m "test: validate branch strategy"

git checkout -b session-3-start-test
git push origin session-3-start-test session-3-complete-test

# Verify checkout works
git checkout session-3-complete-test
# ... verify code state ...

# Clean up test branches
git branch -D session-3-complete-test session-3-start-test
git push origin --delete session-3-complete-test session-3-start-test
```

**Day 4: Gap Analysis**

Full Day (6 hours):
- [ ] Create gap analysis spreadsheet
- [ ] Map each PRD feature to session coverage
- [ ] Identify high/medium/low priority gaps
- [ ] Write gap analysis report with recommendations
- [ ] Create prioritized fix list for immediate sessions

**Day 5: Pre-Build Session 3**

Full Day (6 hours):
```bash
# 14. Pre-build Session 3 features
cd /path/to/heroforge-documind
git checkout -b session-3-complete

# Launch Claude Code and build:
dsp
# [Build all Session 3 features following demo instructions]
exit

# Commit completed work
git add .
git commit -m "feat(session-3): implement Skills, Subagents, Hooks foundation

- Create document-processor Skill
- Implement summarizer Subagent
- Add auto-format Hook
- Configure OpenRouter scaffolding

Follows S3-Demo-Instructions.md"

# Create student starting point
git checkout -b session-3-start main
git push origin session-3-start session-3-complete

# Test demo flow
git checkout session-3-complete
# Walk through code, time yourself explaining each part
```

### 4.6 Success Criteria

**For Analysis Phase**:
- [ ] All 8 sessions have detailed comparison tables
- [ ] PRD coverage matrix is 100% complete
- [ ] Gap analysis report identifies all missing features
- [ ] Prioritized action list exists

**For Branch Strategy**:
- [ ] All session branches created and documented
- [ ] Branch descriptions added to GitHub
- [ ] Instructor can checkout and demo any session in < 2 minutes
- [ ] Students have clear starting points documented

**For Pre-Building**:
- [ ] Sessions 3-5 fully pre-built and tested
- [ ] Sessions 6-10 pre-built before respective class dates
- [ ] All branches pass automated tests (if implemented)
- [ ] Demo flow documented with talking points

**For Gap Resolution**:
- [ ] All "must-fix" gaps addressed before respective sessions
- [ ] "Should-fix" gaps documented for post-course revision
- [ ] PRD updated to reflect actual implementation if scope changed

---

## Section 5: Tooling & Automation

### 5.1 Recommended Tools

**Analysis Tools**:
- Python 3.10+ for extraction scripts
- `markdown` library for parsing
- `pandas` for data manipulation
- `tabulate` for table generation
- `pyyaml` for frontmatter parsing

**Git Tools**:
- `gh` CLI for GitHub operations
- `git-extras` for advanced Git commands
- GitHub Actions for branch validation

**Documentation Tools**:
- Mermaid for flowcharts and diagrams
- Markdown tables generators
- GitHub Projects for tracking progress

### 5.2 Sample Extraction Script

```python
#!/usr/bin/env python3
"""
scripts/analysis/extract_sessions.py

Extract session content from demo-instructions-all.md and workshops-all.md
Generate structured comparison data.
"""

import re
import json
from pathlib import Path
from typing import Dict, List, Tuple
from dataclasses import dataclass, asdict

@dataclass
class SessionContent:
    session_number: int
    title: str
    time_allocated: str
    objectives: List[str]
    activities: List[str]
    code_files: List[str]
    components_built: List[str]
    prd_features: List[str]
    starting_point: str
    deliverables: List[str]

def extract_session(file_content: str, session_num: int, doc_type: str) -> SessionContent:
    """
    Extract a single session's content from markdown file.

    Args:
        file_content: Full markdown file content
        session_num: Session number (3-10)
        doc_type: 'demo' or 'workshop'

    Returns:
        SessionContent object with extracted data
    """
    # Find session section
    pattern = rf"# Session {session_num}:.*?\n(.*?)(?=# Session {session_num + 1}:|$)"
    match = re.search(pattern, file_content, re.DOTALL)

    if not match:
        return None

    section_content = match.group(1)

    # Extract components
    title = extract_title(section_content)
    time_allocated = extract_time(section_content)
    objectives = extract_objectives(section_content)
    activities = extract_activities(section_content)
    code_files = extract_code_files(section_content)
    components_built = extract_components(section_content)
    prd_features = extract_prd_references(section_content)
    starting_point = extract_starting_point(section_content)
    deliverables = extract_deliverables(section_content)

    return SessionContent(
        session_number=session_num,
        title=title,
        time_allocated=time_allocated,
        objectives=objectives,
        activities=activities,
        code_files=code_files,
        components_built=components_built,
        prd_features=prd_features,
        starting_point=starting_point,
        deliverables=deliverables
    )

def extract_title(content: str) -> str:
    """Extract session title from first header."""
    match = re.search(r"#+ Session \d+: (.+)", content)
    return match.group(1) if match else "Unknown"

def extract_time(content: str) -> str:
    """Extract time allocation (e.g., '35 minutes')."""
    match = re.search(r"Time.*?:\s*(\d+\s+minutes?)", content, re.IGNORECASE)
    return match.group(1) if match else "Unknown"

def extract_objectives(content: str) -> List[str]:
    """Extract learning objectives or goals."""
    objectives = []
    # Look for objectives section
    obj_section = re.search(r"## Objectives?(.*?)##", content, re.DOTALL | re.IGNORECASE)
    if obj_section:
        # Extract bullet points
        bullets = re.findall(r"[-*]\s+(.+)", obj_section.group(1))
        objectives = [b.strip() for b in bullets]
    return objectives

def extract_activities(content: str) -> List[str]:
    """Extract main activities or steps."""
    activities = []
    # Look for numbered steps or activity sections
    steps = re.findall(r"###\s+Step \d+:(.+)", content)
    activities = [s.strip() for s in steps]
    return activities

def extract_code_files(content: str) -> List[str]:
    """Extract file paths and names mentioned in code blocks."""
    files = set()
    # Find code blocks with file paths
    code_blocks = re.findall(r"```(?:bash|python|javascript)?\n(.*?)```", content, re.DOTALL)
    for block in code_blocks:
        # Extract file paths (e.g., path/to/file.py, ./dir/file.js)
        paths = re.findall(r"(?:[./][\w/.-]+\.\w+)", block)
        files.update(paths)
    return sorted(list(files))

def extract_components(content: str) -> List[str]:
    """Extract major components built (e.g., 'Skill', 'Subagent', 'RAG pipeline')."""
    components = []
    # Look for common component keywords
    keywords = [
        r"Skill\w*", r"Subagent\w*", r"Hook\w*", r"MCP server",
        r"pipeline", r"agent\w*", r"database", r"API", r"interface"
    ]
    for keyword in keywords:
        matches = re.findall(rf"\b({keyword})\b", content, re.IGNORECASE)
        components.extend(matches)
    return list(set(components))  # Remove duplicates

def extract_prd_references(content: str) -> List[str]:
    """Extract mentions of PRD features or requirements."""
    features = []
    # Look for PRD-related keywords
    prd_keywords = [
        "document processing", "semantic search", "RAG", "vector",
        "embedding", "feedback", "evaluation", "multi-agent"
    ]
    for keyword in prd_keywords:
        if keyword.lower() in content.lower():
            features.append(keyword)
    return features

def extract_starting_point(content: str) -> str:
    """Extract information about starting code state."""
    # Look for mentions of starting branch or checkpoint
    patterns = [
        r"start(?:ing)? from\s+(.+)",
        r"checkout\s+(.+)",
        r"begin(?:ning)? with\s+(.+)"
    ]
    for pattern in patterns:
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            return match.group(1).strip()
    return "Unknown"

def extract_deliverables(content: str) -> List[str]:
    """Extract expected deliverables or outcomes."""
    deliverables = []
    # Look for deliverables section
    deliv_section = re.search(r"## Deliverables?(.*?)##", content, re.DOTALL | re.IGNORECASE)
    if deliv_section:
        bullets = re.findall(r"[-*]\s+(.+)", deliv_section.group(1))
        deliverables = [b.strip() for b in bullets]
    return deliverables

def compare_sessions(demo_content: SessionContent, workshop_content: SessionContent) -> Dict:
    """
    Compare demo and workshop content for a single session.

    Returns:
        Dictionary with comparison metrics
    """
    return {
        "session": demo_content.session_number,
        "demo_title": demo_content.title,
        "workshop_title": workshop_content.title,
        "demo_time": demo_content.time_allocated,
        "workshop_time": workshop_content.time_allocated,
        "overlapping_activities": list(set(demo_content.activities) & set(workshop_content.activities)),
        "demo_only_activities": list(set(demo_content.activities) - set(workshop_content.activities)),
        "workshop_only_activities": list(set(workshop_content.activities) - set(demo_content.activities)),
        "overlapping_components": list(set(demo_content.components_built) & set(workshop_content.components_built)),
        "overlap_percentage": calculate_overlap_percentage(demo_content, workshop_content),
        "recommendation": generate_recommendation(demo_content, workshop_content)
    }

def calculate_overlap_percentage(demo: SessionContent, workshop: SessionContent) -> float:
    """Calculate percentage of overlapping activities and components."""
    demo_items = set(demo.activities + demo.components_built)
    workshop_items = set(workshop.activities + workshop.components_built)

    if not demo_items or not workshop_items:
        return 0.0

    overlap = len(demo_items & workshop_items)
    total = len(demo_items | workshop_items)

    return round((overlap / total) * 100, 1)

def generate_recommendation(demo: SessionContent, workshop: SessionContent) -> str:
    """Generate a recommendation based on overlap analysis."""
    overlap = calculate_overlap_percentage(demo, workshop)

    if overlap > 80:
        return "High overlap - consider pre-building demo and focusing on troubleshooting"
    elif overlap > 50:
        return "Moderate overlap - selective live coding recommended"
    else:
        return "Low overlap - demo and workshop complement each other well"

def main():
    """Main extraction and comparison workflow."""
    base_path = Path(__file__).parent.parent.parent

    # Read files
    demo_file = base_path / "docs/app/demo-instructions-all.md"
    workshop_file = base_path / "docs/app/workshops-all.md"

    with open(demo_file, 'r') as f:
        demo_content = f.read()

    with open(workshop_file, 'r') as f:
        workshop_content = f.read()

    # Extract all sessions (3-10)
    all_comparisons = []

    for session_num in range(3, 11):
        print(f"Processing Session {session_num}...")

        demo_session = extract_session(demo_content, session_num, 'demo')
        workshop_session = extract_session(workshop_content, session_num, 'workshop')

        if demo_session and workshop_session:
            comparison = compare_sessions(demo_session, workshop_session)
            all_comparisons.append(comparison)

            # Save individual session data
            output_dir = base_path / "docs/analysis/sessions"
            output_dir.mkdir(parents=True, exist_ok=True)

            with open(output_dir / f"session-{session_num}-demo.json", 'w') as f:
                json.dump(asdict(demo_session), f, indent=2)

            with open(output_dir / f"session-{session_num}-workshop.json", 'w') as f:
                json.dump(asdict(workshop_session), f, indent=2)

            with open(output_dir / f"session-{session_num}-comparison.json", 'w') as f:
                json.dump(comparison, f, indent=2)

    # Save aggregated comparison
    output_file = base_path / "docs/analysis/all-sessions-comparison.json"
    with open(output_file, 'w') as f:
        json.dump(all_comparisons, f, indent=2)

    print(f"\nExtraction complete. Results saved to {output_file}")
    print(f"Individual session data in docs/analysis/sessions/")

if __name__ == "__main__":
    main()
```

**Usage**:
```bash
chmod +x scripts/analysis/extract_sessions.py
python3 scripts/analysis/extract_sessions.py
```

---

## Section 6: FAQ & Troubleshooting

### 6.1 Common Questions

**Q: Should I pre-build everything or do live coding?**

**A**: Recommended hybrid approach:
- **Pre-build**: Sessions 4-8 (database, multi-agent, RAG, parsing, vectors) - these are complex and error-prone
- **Live code**: Session 3 (foundation) and 9-10 (evaluation) - these are more straightforward and benefit from seeing the process

**Q: If pre-building, should I show the code or build it live anyway?**

**A**: Show-and-explain approach:
1. Checkout pre-built branch
2. Walk through the code explaining design decisions
3. Run the working system
4. Answer questions about implementation
5. Students then build their version in workshop

This is 3-4x faster than live coding and avoids awkward waiting periods.

**Q: Should students build the exact same thing as the demo or something different?**

**A**: From analysis, workshops typically have students build different examples (Session 3) or extend the demo (Sessions 4-10). This is good - students learn by doing, not just copying.

**Q: What if analysis reveals major gaps in PRD coverage?**

**A**: Prioritize:
1. **Must-fix**: Core features missing (e.g., no RAG pipeline in Session 6)
2. **Should-fix**: Important features missing but workarounds exist
3. **Document-only**: Feature scope changed, update PRD to reflect

**Q: How do I handle branch maintenance if I find bugs after a session?**

**A**:
```bash
# Fix in the completed branch
git checkout session-X-complete
# ... make fix ...
git commit -m "fix(session-X): resolve issue with [component]"
git push origin session-X-complete

# If fix affects starting point for next session:
git checkout session-(X+1)-start
git cherry-pick <fix-commit-hash>
git push origin session-(X+1)-start
```

### 6.2 Troubleshooting Scenarios

**Scenario 1: Claude Code takes too long during demo**

**Solution**:
- Have pre-built version ready as backup
- Switch to show-and-explain mode
- Say: "In the interest of time, let me show you the completed version and walk through how it works"

**Scenario 2: Student workshops take longer than expected**

**Solution**:
- Prepare "minimum viable" and "full implementation" versions
- If students falling behind, provide checkpoint branch mid-workshop
- Extend workshop time, reduce demo time next session

**Scenario 3: Git branches get out of sync**

**Solution**:
```bash
# Audit all branches
git branch -a --format='%(refname:short) %(committerdate:relative)'

# Identify issues
git log --oneline --graph --all

# Force-sync if needed (CAREFUL)
git checkout session-X-start
git reset --hard session-(X-1)-complete
git push origin session-X-start --force
```

---

## Section 7: Appendices

### Appendix A: Quick Reference Checklist

**Before Each Session**:
- [ ] Pre-built `session-X-complete` branch exists and tested
- [ ] Student starting point `session-X-start` branch exists
- [ ] Demo talking points documented
- [ ] Common troubleshooting issues identified
- [ ] Workshop time allocation verified
- [ ] Backup plan if live demo fails

**During Demo**:
- [ ] Checkout `session-X-complete` branch
- [ ] Explain design decisions (not just code)
- [ ] Show working system running
- [ ] Connect to PRD requirements
- [ ] Highlight common pitfalls

**During Workshop**:
- [ ] Students start from `session-X-start`
- [ ] Provide real-time support on common issues
- [ ] Monitor progress (are students keeping up?)
- [ ] Adjust pacing if needed

**After Session**:
- [ ] Collect student feedback
- [ ] Note timing issues
- [ ] Document any bugs found
- [ ] Update branch if critical fixes needed
- [ ] Prepare next session based on learnings

### Appendix B: Useful Git Commands

```bash
# List all branches with descriptions
git branch -a --verbose

# Show branch history
git log --oneline --graph --all --decorate

# Checkout specific session state
git checkout session-X-complete

# Compare two session states
git diff session-3-complete..session-4-complete

# Show what changed in a session
git log session-3-complete..session-4-complete --oneline

# Create new session branch from previous
git checkout -b session-5-complete session-4-complete

# Tag a working demo state
git tag -a "demo-s5" -m "Working demo for Session 5"

# Push all branches
git push origin --all

# Push all tags
git push origin --tags
```

### Appendix C: Resources

**Documentation to Create**:
- `/docs/instructor/branch-strategy.md` - Git workflow guide
- `/docs/instructor/session-X-notes.md` - Per-session teaching notes
- `/docs/analysis/session-comparison.md` - Demo vs workshop comparison
- `/docs/analysis/prd-coverage.md` - Feature coverage matrix
- `/docs/analysis/gap-analysis.md` - Identified gaps and recommendations

**Scripts to Create**:
- `/scripts/analysis/extract_sessions.py` - Session content extraction
- `/scripts/analysis/extract_prd.py` - PRD feature extraction
- `/scripts/analysis/generate_comparison.py` - Comparison report generator
- `/scripts/validate_branch.sh` - Branch validation and testing

**GitHub Actions**:
- `.github/workflows/validate-session-branches.yml` - Automated branch testing
- `.github/workflows/demo-deployment.yml` - Demo environment setup

---

## Conclusion

This comprehensive plan provides a systematic approach to addressing all four instructor problems:

1. **Visibility**: Automated extraction and comparison tables show exactly what's built where
2. **Time Management**: Show-and-explain approach with pre-built branches avoids Claude Code wait times
3. **Branch Strategy**: Clear `session-X-start` and `session-X-complete` workflow enables seamless demos
4. **PRD Coverage**: Detailed gap analysis ensures all features are addressed across sessions

**Next Immediate Step**: Run the extraction scripts (Section 4.1) to generate concrete data for all sessions. This will reveal the actual state and enable informed decisions.

**Success Metric**: By the end of this implementation, you'll have:
- Complete visibility into demos vs workshops
- Pre-built, tested branches for all sessions
- Verified PRD coverage with identified gaps addressed
- Confident, time-efficient demo delivery approach

---

**Document Status**: Draft v1.0
**Next Review**: After extraction scripts complete
**Owner**: Course Instructor
