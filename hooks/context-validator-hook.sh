#!/bin/bash
# Context Validator Hook
# Validates documentation consistency and identifies stale context files
#
# This hook checks for documentation inconsistencies when CONTEXT.md files
# are read or modified, helping maintain accurate AI context.
#
# IMPLEMENTATION OVERVIEW:
# - Registered as a PostToolUse hook for Read and Edit tools
# - Detects CONTEXT.md and CLAUDE.md file access
# - Validates references and cross-links
# - Checks for staleness indicators
# - Logs warnings for review

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/context-validation.log"
CONFIG_FILE="$SCRIPT_DIR/config/context-validator.json"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Read input from stdin
INPUT_JSON=$(cat)

# Function to log events
log_event() {
    local event_type="$1"
    local details="$2"
    local severity="${3:-info}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$timestamp\", \"severity\": \"$severity\", \"event\": \"$event_type\", \"details\": \"$details\"}" >> "$LOG_FILE"
}

# Function to check if file is a context file
is_context_file() {
    local file="$1"
    local filename=$(basename "$file")

    if [[ "$filename" == "CONTEXT.md" ]] || [[ "$filename" == "CLAUDE.md" ]]; then
        return 0
    fi

    return 1
}

# Function to validate file references in a context file
validate_references() {
    local context_file="$1"
    local invalid_refs=""
    local dir=$(dirname "$context_file")

    if [[ ! -f "$context_file" ]]; then
        return 0
    fi

    # Extract file references (markdown links and code blocks)
    local refs=$(grep -oE '\[.*?\]\((\.?/?[^)]+)\)' "$context_file" 2>/dev/null | \
                 grep -oE '\([^)]+\)' | tr -d '()' || echo "")

    for ref in $refs; do
        # Skip URLs
        if [[ "$ref" == http* ]] || [[ "$ref" == https* ]] || [[ "$ref" == mailto* ]]; then
            continue
        fi

        # Skip anchors
        if [[ "$ref" == "#"* ]]; then
            continue
        fi

        # Resolve relative paths
        local full_path
        if [[ "$ref" == /* ]]; then
            full_path="$PROJECT_ROOT$ref"
        else
            full_path="$dir/$ref"
        fi

        # Check if file exists
        if [[ ! -e "$full_path" ]]; then
            invalid_refs="$invalid_refs\n  - $ref"
        fi
    done

    if [[ -n "$invalid_refs" ]]; then
        log_event "invalid_references" "File: $context_file$invalid_refs" "warning"
        return 1
    fi

    return 0
}

# Function to check for staleness indicators
check_staleness() {
    local context_file="$1"
    local warnings=""

    if [[ ! -f "$context_file" ]]; then
        return 0
    fi

    local dir=$(dirname "$context_file")

    # Get context file modification time
    local context_mtime
    if [[ "$(uname)" == "Darwin" ]]; then
        context_mtime=$(stat -f %m "$context_file" 2>/dev/null || echo "0")
    else
        context_mtime=$(stat -c %Y "$context_file" 2>/dev/null || echo "0")
    fi

    # Check for source files newer than context
    local newer_files=""
    while IFS= read -r -d '' src_file; do
        local src_mtime
        if [[ "$(uname)" == "Darwin" ]]; then
            src_mtime=$(stat -f %m "$src_file" 2>/dev/null || echo "0")
        else
            src_mtime=$(stat -c %Y "$src_file" 2>/dev/null || echo "0")
        fi

        if [[ "$src_mtime" -gt "$context_mtime" ]]; then
            local relative_file="${src_file#$dir/}"
            newer_files="$newer_files $relative_file"
        fi
    done < <(find "$dir" -maxdepth 2 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) -print0 2>/dev/null)

    if [[ -n "$newer_files" ]]; then
        log_event "potentially_stale" "Context: $context_file may be outdated. Newer files:$newer_files" "info"
    fi

    return 0
}

# Function to validate docs-overview consistency
validate_docs_overview() {
    local docs_overview="$PROJECT_ROOT/docs/ai-context/docs-overview.md"

    if [[ ! -f "$docs_overview" ]]; then
        return 0
    fi

    # Extract documented paths
    local documented_paths=$(grep -oE '\(/[^)]+/CONTEXT\.md\)' "$docs_overview" 2>/dev/null | tr -d '()' || echo "")

    # Check each documented path
    local missing=""
    for path in $documented_paths; do
        local full_path="$PROJECT_ROOT$path"
        if [[ ! -f "$full_path" ]]; then
            missing="$missing\n  - $path"
        fi
    done

    if [[ -n "$missing" ]]; then
        log_event "docs_overview_inconsistency" "Missing documented CONTEXT files:$missing" "warning"
    fi

    # Find undocumented CONTEXT files
    local undocumented=""
    while IFS= read -r -d '' context_file; do
        local relative_path="${context_file#$PROJECT_ROOT}"
        if ! grep -q "$relative_path" "$docs_overview" 2>/dev/null; then
            undocumented="$undocumented\n  - $relative_path"
        fi
    done < <(find "$PROJECT_ROOT" -name "CONTEXT.md" -type f -print0 2>/dev/null)

    if [[ -n "$undocumented" ]]; then
        log_event "undocumented_contexts" "CONTEXT files not in docs-overview:$undocumented" "info"
    fi

    return 0
}

# Main function
main() {
    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')

    # Only process Read and Edit tool calls
    if [[ "$tool_name" != "Read" ]] && [[ "$tool_name" != "Edit" ]]; then
        exit 0
    fi

    # Get the file being accessed
    local file_path=$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // ""')

    if [[ -z "$file_path" ]]; then
        exit 0
    fi

    # Check if this is a context file
    if ! is_context_file "$file_path"; then
        exit 0
    fi

    log_event "context_file_accessed" "$file_path"

    # Run validations
    validate_references "$file_path"
    check_staleness "$file_path"

    # If this is docs-overview, run additional validation
    if [[ "$file_path" == *"docs-overview.md"* ]]; then
        validate_docs_overview
    fi

    # Note: This hook logs warnings but doesn't block operations
    # Warnings can be reviewed in the log file

    exit 0
}

# Run main function
main
