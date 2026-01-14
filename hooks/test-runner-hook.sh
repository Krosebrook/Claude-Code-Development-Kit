#!/bin/bash
# Test Runner Hook
# Validates test execution before git commits or during specific tool calls
#
# This hook ensures code changes don't break existing tests by running
# relevant tests before commits or deployments. It detects the testing
# framework and runs appropriate test suites.
#
# IMPLEMENTATION OVERVIEW:
# - Registered as a PreToolUse hook for Bash tool calls
# - Intercepts git commit commands to run tests first
# - Detects project's testing framework automatically
# - Runs affected tests based on staged files
# - Blocks commits if tests fail

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/test-patterns.json"
LOG_FILE="$SCRIPT_DIR/../logs/test-runner.log"

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

# Function to detect testing framework
detect_test_framework() {
    local framework=""

    # Check for JavaScript/TypeScript frameworks
    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        if grep -q '"jest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            framework="jest"
        elif grep -q '"vitest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            framework="vitest"
        elif grep -q '"mocha"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            framework="mocha"
        fi
    fi

    # Check for Python frameworks
    if [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/pytest.ini" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]]; then
        if [[ -f "$PROJECT_ROOT/pytest.ini" ]] || grep -q "pytest" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null; then
            framework="pytest"
        fi
    fi

    # Check for Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        framework="go"
    fi

    # Check for Rust
    if [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        framework="cargo"
    fi

    echo "$framework"
}

# Function to get test command for framework
get_test_command() {
    local framework="$1"
    local affected_files="$2"

    case "$framework" in
        jest)
            if [[ -n "$affected_files" ]]; then
                echo "npx jest --findRelatedTests $affected_files --passWithNoTests"
            else
                echo "npx jest --passWithNoTests"
            fi
            ;;
        vitest)
            if [[ -n "$affected_files" ]]; then
                echo "npx vitest run --reporter=basic $affected_files"
            else
                echo "npx vitest run --reporter=basic"
            fi
            ;;
        mocha)
            echo "npx mocha"
            ;;
        pytest)
            if [[ -n "$affected_files" ]]; then
                # Convert source files to test file patterns
                echo "pytest -x --tb=short"
            else
                echo "pytest -x --tb=short"
            fi
            ;;
        go)
            echo "go test -short ./..."
            ;;
        cargo)
            echo "cargo test --no-fail-fast"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to get staged files
get_staged_files() {
    cd "$PROJECT_ROOT"
    git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | tr '\n' ' ' || echo ""
}

# Function to filter test-related files
filter_affected_files() {
    local staged_files="$1"
    local affected=""

    for file in $staged_files; do
        # Include source files that might have related tests
        if [[ "$file" == *.ts ]] || [[ "$file" == *.tsx ]] || \
           [[ "$file" == *.js ]] || [[ "$file" == *.jsx ]] || \
           [[ "$file" == *.py ]] || [[ "$file" == *.go ]] || \
           [[ "$file" == *.rs ]]; then
            affected="$affected $file"
        fi
    done

    echo "$affected" | xargs
}

# Function to check if command is a git commit
is_git_commit() {
    local command="$1"
    if echo "$command" | grep -qE '^\s*git\s+commit'; then
        return 0
    fi
    return 1
}

# Function to check if tests are enabled for pre-commit
should_run_tests() {
    # Check if test-patterns.json exists and has pre-commit enabled
    if [[ -f "$CONFIG_FILE" ]]; then
        local enabled=$(jq -r '.pre_commit.enabled // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
        [[ "$enabled" == "true" ]]
        return $?
    fi
    # Default to disabled if config doesn't exist
    return 1
}

# Main function
main() {
    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')

    # Only process Bash tool calls
    if [[ "$tool_name" != "Bash" ]]; then
        echo '{"continue": true}'
        exit 0
    fi

    # Extract the command
    local command=$(echo "$INPUT_JSON" | jq -r '.tool_input.command // ""')

    # Only intercept git commit commands
    if ! is_git_commit "$command"; then
        echo '{"continue": true}'
        exit 0
    fi

    # Check if pre-commit tests are enabled
    if ! should_run_tests; then
        log_event "skipped" "pre-commit tests disabled in configuration"
        echo '{"continue": true}'
        exit 0
    fi

    log_event "triggered" "git commit detected, running pre-commit tests"

    # Detect framework
    local framework=$(detect_test_framework)

    if [[ -z "$framework" ]]; then
        log_event "skipped" "no testing framework detected"
        echo '{"continue": true}'
        exit 0
    fi

    log_event "framework_detected" "$framework"

    # Get staged files
    local staged_files=$(get_staged_files)
    local affected_files=$(filter_affected_files "$staged_files")

    # Get test command
    local test_cmd=$(get_test_command "$framework" "$affected_files")

    if [[ -z "$test_cmd" ]]; then
        log_event "error" "could not determine test command"
        echo '{"continue": true}'
        exit 0
    fi

    log_event "running_tests" "$test_cmd"

    # Run tests
    cd "$PROJECT_ROOT"
    local test_output
    local test_exit_code

    test_output=$(eval "$test_cmd" 2>&1) || test_exit_code=$?
    test_exit_code=${test_exit_code:-0}

    if [[ $test_exit_code -ne 0 ]]; then
        log_event "tests_failed" "exit code: $test_exit_code"

        # Format error message
        local error_summary=$(echo "$test_output" | tail -20)

        echo "{\"decision\": \"block\", \"reason\": \"Pre-commit tests failed. Please fix the failing tests before committing.\\n\\nTest Output:\\n$error_summary\"}"
        exit 2
    fi

    log_event "tests_passed" "all tests passed"

    # Tests passed, allow the commit
    echo '{"continue": true}'
}

# Run main function
main
