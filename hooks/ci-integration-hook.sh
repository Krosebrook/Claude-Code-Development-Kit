#!/bin/bash
# CI Integration Hook
# Analyzes project structure and suggests CI/CD configurations
#
# This hook detects when CI/CD-related files are being created or modified
# and provides intelligent suggestions based on project structure.
#
# IMPLEMENTATION OVERVIEW:
# - Registered as a PostToolUse hook for Write tool
# - Detects CI/CD config file creation
# - Analyzes project structure
# - Suggests comprehensive CI/CD configurations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/ci-integration.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Read input from stdin
INPUT_JSON=$(cat)

# Function to log events
log_event() {
    local event_type="$1"
    local details="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$timestamp\", \"event\": \"$event_type\", \"details\": \"$details\"}" >> "$LOG_FILE"
}

# Function to detect project type
detect_project_type() {
    local types=""

    # JavaScript/TypeScript
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        types="$types nodejs"
        if grep -q '"typescript"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            types="$types typescript"
        fi
        if grep -q '"react"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            types="$types react"
        fi
        if grep -q '"vue"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            types="$types vue"
        fi
    fi

    # Python
    if [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/requirements.txt" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]]; then
        types="$types python"
    fi

    # Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        types="$types go"
    fi

    # Rust
    if [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        types="$types rust"
    fi

    # Docker
    if [[ -f "$PROJECT_ROOT/Dockerfile" ]]; then
        types="$types docker"
    fi

    echo "$types"
}

# Function to detect package manager
detect_package_manager() {
    if [[ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "$PROJECT_ROOT/yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
        echo "npm"
    elif [[ -f "$PROJECT_ROOT/Pipfile.lock" ]]; then
        echo "pipenv"
    elif [[ -f "$PROJECT_ROOT/poetry.lock" ]]; then
        echo "poetry"
    else
        echo "unknown"
    fi
}

# Function to check if file is CI/CD related
is_ci_file() {
    local file="$1"
    local filename=$(basename "$file")
    local dirname=$(dirname "$file")

    # GitHub Actions
    if [[ "$file" == *".github/workflows/"* ]]; then
        return 0
    fi

    # GitLab CI
    if [[ "$filename" == ".gitlab-ci.yml" ]]; then
        return 0
    fi

    # CircleCI
    if [[ "$file" == *".circleci/config.yml"* ]]; then
        return 0
    fi

    # Jenkins
    if [[ "$filename" == "Jenkinsfile" ]]; then
        return 0
    fi

    # Travis CI
    if [[ "$filename" == ".travis.yml" ]]; then
        return 0
    fi

    return 1
}

# Function to generate CI suggestions
generate_ci_suggestions() {
    local project_types="$1"
    local package_manager="$2"

    local suggestions=""

    # Base suggestions
    suggestions="## CI/CD Suggestions\n\n"

    # Node.js projects
    if [[ "$project_types" == *"nodejs"* ]]; then
        suggestions="$suggestions### Node.js Pipeline\n"
        suggestions="$suggestions- Use $package_manager for dependency installation\n"
        suggestions="$suggestions- Cache node_modules for faster builds\n"
        suggestions="$suggestions- Run linting, type checking, and tests in parallel\n"

        if [[ "$project_types" == *"typescript"* ]]; then
            suggestions="$suggestions- Include TypeScript compilation step\n"
        fi
    fi

    # Python projects
    if [[ "$project_types" == *"python"* ]]; then
        suggestions="$suggestions### Python Pipeline\n"
        suggestions="$suggestions- Use $package_manager for dependency management\n"
        suggestions="$suggestions- Include pytest for testing\n"
        suggestions="$suggestions- Run type checking with mypy\n"
        suggestions="$suggestions- Include security scanning with pip-audit or safety\n"
    fi

    # Go projects
    if [[ "$project_types" == *"go"* ]]; then
        suggestions="$suggestions### Go Pipeline\n"
        suggestions="$suggestions- Run go vet and staticcheck\n"
        suggestions="$suggestions- Include go test with coverage\n"
        suggestions="$suggestions- Use govulncheck for security\n"
    fi

    # Docker projects
    if [[ "$project_types" == *"docker"* ]]; then
        suggestions="$suggestions### Docker Pipeline\n"
        suggestions="$suggestions- Include Docker build step\n"
        suggestions="$suggestions- Run security scanning on images\n"
        suggestions="$suggestions- Push to registry on successful builds\n"
    fi

    echo -e "$suggestions"
}

# Main function
main() {
    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')

    # Only process Write tool calls
    if [[ "$tool_name" != "Write" ]]; then
        exit 0
    fi

    # Get the file being written
    local file_path=$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // ""')

    if [[ -z "$file_path" ]]; then
        exit 0
    fi

    # Check if this is a CI/CD file
    if ! is_ci_file "$file_path"; then
        exit 0
    fi

    log_event "ci_file_detected" "$file_path"

    # Detect project characteristics
    local project_types=$(detect_project_type)
    local package_manager=$(detect_package_manager)

    log_event "project_analysis" "types: $project_types, package_manager: $package_manager"

    # Generate and log suggestions
    local suggestions=$(generate_ci_suggestions "$project_types" "$package_manager")
    log_event "suggestions_generated" "CI/CD suggestions available in log"

    # Note: This hook logs suggestions but doesn't block the operation
    # The suggestions can be retrieved from the log file

    exit 0
}

# Run main function
main
