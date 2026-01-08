#!/bin/bash
# Test Context Injector Hook
# Automatically enhances test-related Task prompts with testing context
#
# This hook ensures test-focused sub-agents receive relevant testing
# documentation, framework patterns, and project test conventions,
# enabling more accurate test generation and analysis.
#
# IMPLEMENTATION OVERVIEW:
# - Registered as a PreToolUse hook for Task tool
# - Detects test-related prompts via keyword matching
# - Injects references to test documentation and patterns
# - Includes framework-specific testing context
# - Preserves original prompt by prepending context

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/test-patterns.json"
LOG_FILE="$SCRIPT_DIR/../logs/test-context-injection.log"

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
    local framework="unknown"

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
    if [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/pytest.ini" ]]; then
        if grep -q "pytest" "$PROJECT_ROOT/pyproject.toml" 2>/dev/null || [[ -f "$PROJECT_ROOT/pytest.ini" ]]; then
            framework="pytest"
        fi
    fi

    # Check for Go
    if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
        framework="go-test"
    fi

    # Check for Rust
    if [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
        framework="cargo-test"
    fi

    echo "$framework"
}

# Function to find existing test directories
find_test_directories() {
    local test_dirs=""

    # Common test directory patterns
    local patterns=("tests" "test" "__tests__" "spec" "specs" "test_*" "*_test")

    for pattern in "${patterns[@]}"; do
        local found=$(find "$PROJECT_ROOT" -maxdepth 3 -type d -name "$pattern" 2>/dev/null | head -3)
        if [[ -n "$found" ]]; then
            test_dirs="$test_dirs $found"
        fi
    done

    echo "$test_dirs" | xargs
}

# Function to find test configuration files
find_test_config() {
    local config_files=""

    # Common test config files
    local configs=(
        "jest.config.js" "jest.config.ts" "jest.config.json"
        "vitest.config.js" "vitest.config.ts"
        "pytest.ini" "pyproject.toml" "setup.cfg"
        "mocha.opts" ".mocharc.js" ".mocharc.json"
    )

    for config in "${configs[@]}"; do
        if [[ -f "$PROJECT_ROOT/$config" ]]; then
            config_files="$config_files $config"
        fi
    done

    echo "$config_files" | xargs
}

# Function to check if prompt is test-related
is_test_related() {
    local prompt="$1"
    local prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

    # Test-related keywords
    local keywords=("test" "spec" "coverage" "mock" "stub" "fixture" "assert" "expect" "jest" "pytest" "vitest" "mocha" "unittest" "testing")

    for keyword in "${keywords[@]}"; do
        if echo "$prompt_lower" | grep -qw "$keyword"; then
            return 0
        fi
    done

    return 1
}

# Function to build framework-specific context
build_framework_context() {
    local framework="$1"

    case "$framework" in
        jest)
            cat << 'EOF'
### Testing Framework: Jest

**Key Patterns**:
- Use `describe()` for grouping, `it()` or `test()` for cases
- `beforeEach()`/`afterEach()` for setup/teardown
- `jest.mock()` for module mocking
- `expect()` with matchers like `.toBe()`, `.toEqual()`, `.toThrow()`

**Best Practices**:
- Use `jest.spyOn()` for partial mocking
- Prefer `toMatchSnapshot()` sparingly for complex outputs
- Use `--findRelatedTests` for targeted test runs
EOF
            ;;
        vitest)
            cat << 'EOF'
### Testing Framework: Vitest

**Key Patterns**:
- Compatible with Jest API (`describe`, `it`, `expect`)
- `vi.mock()` for mocking (similar to jest.mock)
- `vi.spyOn()` for spies
- Native ESM support

**Best Practices**:
- Leverage faster execution for TDD workflows
- Use `--reporter=verbose` for detailed output
- Built-in coverage with c8
EOF
            ;;
        pytest)
            cat << 'EOF'
### Testing Framework: pytest

**Key Patterns**:
- Functions starting with `test_` are auto-discovered
- Use `@pytest.fixture` for setup/teardown
- `@pytest.mark.parametrize` for data-driven tests
- `pytest.raises()` for exception testing

**Best Practices**:
- Use `conftest.py` for shared fixtures
- Prefer `pytest-asyncio` for async code
- Use `-x` flag to stop on first failure
- Use `--tb=short` for concise tracebacks
EOF
            ;;
        go-test)
            cat << 'EOF'
### Testing Framework: Go Test

**Key Patterns**:
- Test functions: `func TestXxx(t *testing.T)`
- Table-driven tests with `t.Run()`
- Use `testify` package for cleaner assertions
- `t.Parallel()` for concurrent tests

**Best Practices**:
- Use interfaces for mockability
- Prefer `httptest` for HTTP testing
- Use `-race` flag to detect race conditions
- Use `-short` for quick test runs
EOF
            ;;
        cargo-test)
            cat << 'EOF'
### Testing Framework: Cargo Test

**Key Patterns**:
- Use `#[test]` attribute for test functions
- `#[should_panic]` for expected panics
- Use `assert!`, `assert_eq!`, `assert_ne!` macros
- Integration tests in `tests/` directory

**Best Practices**:
- Use `#[cfg(test)]` module for test-only code
- Prefer `tokio-test` for async testing
- Use `--no-capture` to see println! output
EOF
            ;;
        *)
            cat << 'EOF'
### Testing Guidelines

**General Best Practices**:
- Follow Arrange-Act-Assert pattern
- Test one behavior per test case
- Use descriptive test names
- Mock external dependencies
- Cover happy path, edge cases, and error handling
EOF
            ;;
    esac
}

# Main function
main() {
    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')

    # Only process Task tool calls
    if [[ "$tool_name" != "Task" ]]; then
        echo '{"continue": true}'
        exit 0
    fi

    # Extract current prompt
    local current_prompt=$(echo "$INPUT_JSON" | jq -r '.tool_input.prompt // ""')

    # Check if prompt is test-related
    if ! is_test_related "$current_prompt"; then
        # Not test-related, pass through unchanged
        echo '{"continue": true}'
        exit 0
    fi

    log_event "test_context_injection" "enhancing test-related prompt"

    # Detect framework and gather context
    local framework=$(detect_test_framework)
    local test_dirs=$(find_test_directories)
    local test_configs=$(find_test_config)
    local framework_context=$(build_framework_context "$framework")

    # Build context injection
    local context_injection="## Testing Context (Auto-Injected)

This sub-agent has been detected as working on testing tasks. Here is relevant context:

### Detected Testing Framework: $framework

### Test Directories Found
$(if [[ -n "$test_dirs" ]]; then
    for dir in $test_dirs; do
        echo "- $dir"
    done
else
    echo "- No standard test directories found"
fi)

### Test Configuration Files
$(if [[ -n "$test_configs" ]]; then
    for config in $test_configs; do
        echo "- $config"
    done
else
    echo "- No test configuration files found"
fi)

$framework_context

### Testing Principles
- Follow existing test patterns in the codebase
- Maintain consistent naming conventions
- Write tests that provide genuine value
- Cover edge cases and error handling
- Keep tests maintainable and readable

---

## Your Task

"

    # Combine context with original prompt
    local modified_prompt="${context_injection}${current_prompt}"

    # Update the input JSON with modified prompt
    local output_json=$(echo "$INPUT_JSON" | jq --arg new_prompt "$modified_prompt" '.tool_input.prompt = $new_prompt')

    log_event "injection_complete" "framework: $framework, test_dirs: $test_dirs"

    # Output modified JSON
    echo "$output_json"
}

# Run main function
main
