#!/bin/bash
# Check if source files affecting test results have changed
# Usage: check-source-changes.sh [pattern1] [pattern2] ...
# Example: check-source-changes.sh 'pubspec.yaml' 'lib/**' 'test/**'

# Get patterns from arguments
if [ $# -eq 0 ]; then
  echo "Error: No patterns specified"
  echo "Usage: $0 pattern1 [pattern2] ..."
  exit 1
fi

PATTERNS=("$@")

# Determine comparison reference
# - For PRs with previous check: compare against last checked commit
# - For PRs (first check): compare against base branch
# - For pushes: compare against previous commit
if [ -n "$GITHUB_BASE_REF" ]; then
  # Pull Request event
  if [ -n "$PR_BEFORE_SHA" ] && [ "$PR_BEFORE_SHA" != "0000000000000000000000000000000000000000" ]; then
    # Subsequent PR check: compare against previous head
    COMPARE_REF="$PR_BEFORE_SHA"
    echo "Comparing against previous PR head: $COMPARE_REF"
  else
    # First PR check: compare against base branch
    git fetch origin "$GITHUB_BASE_REF" --depth=1 2>/dev/null
    COMPARE_REF="origin/$GITHUB_BASE_REF"
    echo "Comparing against base branch: $COMPARE_REF"
  fi
else
  # Push event: compare against previous commit
  COMPARE_REF="HEAD~1"
  echo "Comparing against previous commit: $COMPARE_REF"
fi

# Get list of changed files
CHANGED_FILES=$(git diff --name-only "$COMPARE_REF" HEAD 2>/dev/null || echo "")

# If no changed files detected (e.g., initial commit), run tests
if [ -z "$CHANGED_FILES" ]; then
  echo "No previous commit found, running tests"
  echo "should-test=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

# Check if any changed file matches the patterns
for file in $CHANGED_FILES; do
  for pattern in "${PATTERNS[@]}"; do
    # Direct match
    if [[ "$file" == "$pattern" ]]; then
      echo "Changed: $file (matches $pattern)"
      echo "should-test=true" >> "$GITHUB_OUTPUT"
      exit 0
    fi
    # Wildcard match for directory patterns
    if [[ "$pattern" == *"**" ]]; then
      dir_prefix="${pattern%/**}"
      if [[ "$file" == "$dir_prefix"/* ]]; then
        echo "Changed: $file (matches $pattern)"
        echo "should-test=true" >> "$GITHUB_OUTPUT"
        exit 0
      fi
    fi
  done
done

echo "No source files changed, skipping tests"
echo "should-test=false" >> "$GITHUB_OUTPUT"
