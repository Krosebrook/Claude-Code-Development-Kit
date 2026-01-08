#!/bin/bash
# Test Watcher Hook
# Monitors file changes and provides continuous testing feedback
#
# This hook runs after file write operations to automatically execute
# related tests, providing immediate feedback on code changes. It helps
# maintain a tight feedback loop during development.
#
# IMPLEMENTATION OVERVIEW:
# - Registered as a PostToolUse hook for Write and Edit tools
# - Detects when source files are modified
# - Runs related tests automatically
# - Provides audio/visual feedback on test results
# - Logs test execution for debugging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/test-patterns.json"
LOG_FILE="$SCRIPT_DIR/../logs/test-watcher.log"
NOTIFY_SCRIPT="$SCRIPT_DIR/notify.sh"

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

# Function to check if watcher is enabled
is_watcher_enabled() {
    if [[ -f "$CONFIG_FILE" ]]; then
        local enabled=$(jq -r '.watch_mode.enabled // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
        [[ "$enabled" == "true" ]]
        return $?
    fi
    return 1
}

# Function to detect testing framework
detect_test_framework() {
    local framework=""

    if [[ -f "$PROJECT_ROOT/package.json" ]]; then
        if grep -q '"jest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            framework="jest"
        elif grep -q '"vitest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            framework="vitest"
        fi
    elif [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/pytest.ini" ]]; then
        framework="pytest"
    elif [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        framework="go"
    elif [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        framework="cargo"
    fi

    echo "$framework"
}

# Function to find related test file
find_related_test() {
    local source_file="$1"
    local basename=$(basename "$source_file")
    local dirname=$(dirname "$source_file")
    local name_without_ext="${basename%.*}"
    local ext="${basename##*.}"

    # Common test file patterns
    local test_patterns=(
        "$dirname/$name_without_ext.test.$ext"
        "$dirname/$name_without_ext.spec.$ext"
        "$dirname/__tests__/$name_without_ext.test.$ext"
        "$dirname/__tests__/$name_without_ext.spec.$ext"
        "${dirname/src/test}/$name_without_ext.test.$ext"
        "${dirname/src/tests}/$name_without_ext.test.$ext"
        "$dirname/test_$name_without_ext.py"
        "${dirname}_test.go"
    )

    for pattern in "${test_patterns[@]}"; do
        if [[ -f "$PROJECT_ROOT/$pattern" ]]; then
            echo "$pattern"
            return 0
        fi
    done

    # For test files themselves, return the file
    if echo "$basename" | grep -qE '\.(test|spec)\.' || echo "$basename" | grep -qE '^test_'; then
        echo "$source_file"
        return 0
    fi

    return 1
}

# Function to run tests for a file
run_related_tests() {
    local file="$1"
    local framework="$2"
    local test_file=$(find_related_test "$file")

    if [[ -z "$test_file" ]]; then
        log_event "no_related_tests" "$file"
        return 0
    fi

    local test_cmd=""
    local timeout_seconds=30

    case "$framework" in
        jest)
            test_cmd="npx jest --findRelatedTests $file --passWithNoTests --testTimeout=10000"
            ;;
        vitest)
            test_cmd="npx vitest run $test_file --reporter=basic"
            ;;
        pytest)
            test_cmd="pytest $test_file -x --tb=short -q"
            ;;
        go)
            local pkg_dir=$(dirname "$file")
            test_cmd="go test -short -timeout ${timeout_seconds}s ./$pkg_dir/..."
            ;;
        cargo)
            test_cmd="cargo test --no-fail-fast -- --test-threads=1"
            ;;
        *)
            log_event "unknown_framework" "$framework"
            return 0
            ;;
    esac

    log_event "running_tests" "$test_cmd"

    cd "$PROJECT_ROOT"

    # Run tests with timeout
    local test_output
    local test_exit_code

    test_output=$(timeout "$timeout_seconds" bash -c "$test_cmd" 2>&1) || test_exit_code=$?
    test_exit_code=${test_exit_code:-0}

    if [[ $test_exit_code -eq 0 ]]; then
        log_event "tests_passed" "$file"
        # Play success sound if notify script exists
        if [[ -x "$NOTIFY_SCRIPT" ]]; then
            "$NOTIFY_SCRIPT" complete &
        fi
        return 0
    elif [[ $test_exit_code -eq 124 ]]; then
        log_event "tests_timeout" "$file"
        return 1
    else
        log_event "tests_failed" "exit code: $test_exit_code, file: $file"
        # Play failure sound
        if [[ -x "$NOTIFY_SCRIPT" ]]; then
            "$NOTIFY_SCRIPT" input &
        fi
        return 1
    fi
}

# Function to check if file should trigger tests
should_trigger_tests() {
    local file="$1"

    # Skip non-source files
    local ext="${file##*.}"
    local valid_extensions=("ts" "tsx" "js" "jsx" "py" "go" "rs" "rb" "java" "kt" "swift")

    for valid_ext in "${valid_extensions[@]}"; do
        if [[ "$ext" == "$valid_ext" ]]; then
            return 0
        fi
    done

    return 1
}

# Function to extract file path from tool result
get_modified_file() {
    local tool_name="$1"

    case "$tool_name" in
        Write|Edit)
            echo "$INPUT_JSON" | jq -r '.tool_input.file_path // ""'
            ;;
        *)
            echo ""
            ;;
    esac
}

# Main function
main() {
    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')

    # Only process Write and Edit tool calls
    if [[ "$tool_name" != "Write" ]] && [[ "$tool_name" != "Edit" ]]; then
        exit 0
    fi

    # Check if watcher is enabled
    if ! is_watcher_enabled; then
        exit 0
    fi

    # Get the modified file
    local modified_file=$(get_modified_file "$tool_name")

    if [[ -z "$modified_file" ]]; then
        exit 0
    fi

    # Make path relative to project root
    modified_file="${modified_file#$PROJECT_ROOT/}"

    # Check if this file type should trigger tests
    if ! should_trigger_tests "$modified_file"; then
        log_event "skipped" "non-source file: $modified_file"
        exit 0
    fi

    # Detect framework
    local framework=$(detect_test_framework)

    if [[ -z "$framework" ]]; then
        log_event "skipped" "no framework detected"
        exit 0
    fi

    # Run related tests in background to not block the main workflow
    (run_related_tests "$modified_file" "$framework") &

    exit 0
}

# Run main function
main
