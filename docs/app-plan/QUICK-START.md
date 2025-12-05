# Quick Start Guide - Course Analysis & Planning

**Time Required**: 30-60 minutes
**Prerequisites**: Python 3.10+, access to course repository

---

## Overview

This quick-start guide helps you:
1. ✅ Analyze demos vs workshops across sessions 3-10
2. ✅ Verify PRD feature coverage
3. ✅ Identify which sessions to pre-build
4. ✅ Plan your Git branch strategy

## Step 1: Run Analysis Scripts (10 minutes)

```bash
# Navigate to course repository root
cd /workspaces/course-ai-software-dev

# Run session comparison analysis
python3 scripts/analysis/extract_sessions.py

# Run PRD feature extraction
python3 scripts/analysis/extract_prd_features.py
```

**Expected Output**:
```
Session Content Extraction and Comparison Tool
===============================================================
Processing Session 3... ✓ (Overlap: XX%)
Processing Session 4... ✓ (Overlap: XX%)
...
Extraction Complete!
Results saved to:
  - JSON summary: docs/analysis/all-sessions-comparison.json
  - Markdown summary: docs/analysis/session-comparison-summary.md
```

## Step 2: Review Session Comparison (15 minutes)

Open the comparison summary:
```bash
code docs/analysis/session-comparison-summary.md
```

**What to look for**:

### High Overlap Sessions (>80%)
These are **strong candidates for pre-building**:
- Students will rebuild what you just showed
- Live coding creates dead air due to Claude Code response time
- **Action**: Pre-build these sessions, use show-and-explain approach

### Moderate Overlap Sessions (50-80%)
These **benefit from selective pre-building**:
- Some duplication, but students extend the demo
- **Action**: Pre-build complex parts, live-code simple extensions

### Low Overlap Sessions (<50%)
These **complement each other well**:
- Demo shows one example, workshop has students build different example
- **Action**: Can live-code if comfortable, or pre-build for consistency

**Mark your decisions**:
```markdown
Session 3: __% overlap → Pre-build? YES / NO / PARTIAL
Session 4: __% overlap → Pre-build? YES / NO / PARTIAL
Session 5: __% overlap → Pre-build? YES / NO / PARTIAL
...
```

## Step 3: Review PRD Coverage (10 minutes)

Open the PRD summary:
```bash
code docs/analysis/prd-features-summary.md
```

**What to check**:

For each session 3-10, verify:
- [ ] All PRD roadmap features are present in demo or workshop
- [ ] Database tables are created in appropriate sessions
- [ ] Architecture components are implemented
- [ ] Success metrics are achievable

**Identify Gaps**:
```markdown
Session X:
  Missing: [Feature Y from PRD]
  Reason: [Why it's missing]
  Priority: HIGH / MEDIUM / LOW
  Action: [Add to demo / Add to workshop / Document as out-of-scope]
```

## Step 4: Create Your Branch Strategy (10 minutes)

Based on your pre-build decisions, plan your branches:

**Recommended Structure**:
```
main (complete system)
├── session-3-start (empty foundation)
├── session-3-complete (Skills, Subagents, Hooks)
├── session-4-start (= session-3-complete)
├── session-4-complete (Supabase + MCP)
├── session-5-start (= session-4-complete)
├── session-5-complete (Multi-agent processing)
...
└── session-10-complete (Full DocuMind system)
```

**Document your plan**:
```bash
cat > docs/instructor/my-branch-plan.md << 'EOF'
# My Branch Strategy

## Sessions to Pre-Build
- [ ] Session 3: [YES/NO] - Reason: [...]
- [ ] Session 4: [YES/NO] - Reason: [...]
- [ ] Session 5: [YES/NO] - Reason: [...]
...

## Timeline
- Week 1: Pre-build Sessions 3-5
- Week 2: Pre-build Sessions 6-8
- Week 3: Pre-build Sessions 9-10
- Week 4: Final testing and documentation
EOF
```

## Step 5: Review Comprehensive Plan (15 minutes)

Read the full analysis plan:
```bash
code docs/planning/comprehensive-course-analysis-plan.md
```

**Key sections to review**:
- **Section 2**: Branch Strategy Details (Git workflow, naming conventions)
- **Section 3**: Gap Analysis Framework (how to identify missing features)
- **Section 4**: Implementation Roadmap (week-by-week action plan)

**Bookmark important sections** for reference during implementation.

## Step 6: Next Actions (Immediate)

Based on your analysis, choose your path:

### Path A: Pre-Build Everything Now (Bulk Approach)
**Time**: 2-3 full days
**When**: You have time before course starts
**Steps**:
1. Block out 2-3 days
2. Pre-build sessions 3-10 sequentially
3. Create all branches at once
4. Test entire flow
5. Document any issues

### Path B: Pre-Build Incrementally (Recommended)
**Time**: 4-6 hours per session
**When**: Teaching course soon, limited prep time
**Steps**:
1. Pre-build next 2 sessions before each class
2. Create branches for those sessions
3. Test demo flow
4. Adjust based on student feedback

### Path C: Hybrid Approach
**Time**: 1-2 days
**When**: Want balance of preparation and flexibility
**Steps**:
1. Pre-build high-overlap sessions (4, 5, 6, 8)
2. Live-code low-overlap sessions (3, 7, 9, 10)
3. Create branches only for pre-built sessions

**Mark your choice**:
```
I will use: [ ] Path A [ ] Path B [ ] Path C
```

## Step 7: Set Up for Pre-Building (If Applicable)

If you chose to pre-build, set up your environment:

```bash
# 1. Navigate to student repository (heroforge-documind)
cd /path/to/heroforge-documind

# 2. Ensure clean state
git status

# 3. Create session-3-complete branch
git checkout -b session-3-complete

# 4. Launch Claude Code
dsp

# 5. Start building following demo instructions
# docs/app/demo-instructions-all.md - Session 3
```

## Troubleshooting

### Scripts Don't Run
```bash
# Check Python version (need 3.10+)
python3 --version

# If modules missing:
# Scripts use only standard library, no pip install needed
```

### Session Not Found Errors
**Cause**: Session header format doesn't match expected pattern
**Fix**: Check if markdown uses different header levels or naming

### No Overlap Calculated
**Cause**: Activities/components extraction found no matches
**Fix**: Review `session-X-comparison.json` to see what was extracted

### PRD Features Not Mapping to Sessions
**Cause**: Keyword matching didn't find correlations
**Fix**: Manually review and update `expected_session` in `prd-features.json`

## Quick Reference

### Analysis Output Files
```
docs/analysis/
├── session-comparison-summary.md     ← START HERE (session comparison)
├── prd-features-summary.md           ← THEN HERE (PRD features)
├── all-sessions-comparison.json      ← Raw data (for scripts)
└── prd-features.json                 ← Raw data (for scripts)
```

### Key Commands
```bash
# Re-run analysis
python3 scripts/analysis/extract_sessions.py
python3 scripts/analysis/extract_prd_features.py

# View results
code docs/analysis/session-comparison-summary.md
code docs/analysis/prd-features-summary.md

# Check specific session
cat docs/analysis/sessions/session-5-comparison.json | jq '.'
```

### Decision Checklist

Before each session, decide:
- [ ] Will I pre-build or live-code?
- [ ] If pre-building, when will I build it?
- [ ] What branch will students start from?
- [ ] What troubleshooting issues should I prepare for?
- [ ] How much time for demo vs workshop?

## Next Steps

After completing this quick start:

1. ✅ You have analyzed all sessions (demos vs workshops)
2. ✅ You have verified PRD coverage
3. ✅ You have identified pre-build candidates
4. ✅ You have a branch strategy plan

**Now proceed to**:
- [ ] Implement your branch strategy (Section 2 of comprehensive plan)
- [ ] Address any PRD coverage gaps (Section 3 of comprehensive plan)
- [ ] Follow week-by-week implementation roadmap (Section 4 of comprehensive plan)

## Summary: Your 3 Key Decisions

Write these down:

1. **Which sessions will I pre-build?**
   - Sessions: _________________________

2. **Which branch strategy will I use?**
   - [ ] session-X-start + session-X-complete
   - [ ] Tag-based (session-X-complete tags)
   - [ ] Other: _________________________

3. **When will I pre-build?**
   - [ ] All at once (before course)
   - [ ] Incrementally (1-2 sessions ahead)
   - [ ] Hybrid (critical sessions only)

**Keep these decisions visible** during your implementation.

---

## Need Help?

- **Comprehensive details**: `docs/planning/comprehensive-course-analysis-plan.md`
- **Script documentation**: `scripts/analysis/README.md`
- **Analysis results**: `docs/analysis/`

**Time to complete Quick Start**: 30-60 minutes
**Result**: Clear understanding of course structure and pre-build needs

---

**Created**: 2025-12-01
**For**: AI Software Development Course Instructor
**Purpose**: Rapid course analysis and decision-making
