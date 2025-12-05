#!/bin/bash
# DocuMind Pre-Commit Format Hook
# Automatically formats files before commit

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[DocuMind] Running pre-commit formatting...${NC}"

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}[DocuMind] No staged files to format${NC}"
    exit 0
fi

FILES_MODIFIED=0

# Format Python files with black
PYTHON_FILES=$(echo "$STAGED_FILES" | grep -E '\.py$' || true)
if [ -n "$PYTHON_FILES" ]; then
    if command -v black &> /dev/null; then
        echo -e "${YELLOW}[DocuMind] Formatting Python files...${NC}"
        echo "$PYTHON_FILES" | xargs black --quiet 2>/dev/null || true
        FILES_MODIFIED=1
    fi
fi

# Clean up Markdown files
MD_FILES=$(echo "$STAGED_FILES" | grep -E '\.md$' || true)
if [ -n "$MD_FILES" ]; then
    echo -e "${YELLOW}[DocuMind] Cleaning up Markdown files...${NC}"
    for file in $MD_FILES; do
        if [ -f "$file" ]; then
            sed -i'' -e 's/[[:space:]]*$//' "$file" 2>/dev/null || true
            FILES_MODIFIED=1
        fi
    done
fi

if [ $FILES_MODIFIED -eq 1 ]; then
    echo "$STAGED_FILES" | xargs git add 2>/dev/null || true
    echo -e "${GREEN}[DocuMind] Files formatted and re-staged${NC}"
fi

echo -e "${GREEN}[DocuMind] Pre-commit formatting complete${NC}"
exit 0
