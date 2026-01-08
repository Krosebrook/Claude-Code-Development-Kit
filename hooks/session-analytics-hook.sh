#!/bin/bash
# Session Analytics Hook
# Tracks command usage and session patterns for insights
#
# This hook collects anonymous usage statistics to help understand
# which commands are most useful and identify improvement opportunities.
#
# IMPLEMENTATION OVERVIEW:
# - Registered as a PreToolUse hook for all tools
# - Tracks command invocations and patterns
# - Stores data locally only (no external transmission)
# - Provides aggregated insights via /analytics command

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ANALYTICS_FILE="$SCRIPT_DIR/../logs/session-analytics.json"
LOG_FILE="$SCRIPT_DIR/../logs/session-analytics.log"
CONFIG_FILE="$SCRIPT_DIR/config/analytics-config.json"

# Ensure log directory exists
mkdir -p "$(dirname "$ANALYTICS_FILE")"

# Read input from stdin
INPUT_JSON=$(cat)

# Function to log events
log_event() {
    local event_type="$1"
    local details="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\": \"$timestamp\", \"event\": \"$event_type\", \"details\": \"$details\"}" >> "$LOG_FILE"
}

# Function to check if analytics is enabled
is_analytics_enabled() {
    if [[ -f "$CONFIG_FILE" ]]; then
        local enabled=$(jq -r '.enabled // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
        [[ "$enabled" == "true" ]]
        return $?
    fi
    # Disabled by default
    return 1
}

# Function to initialize analytics file if needed
initialize_analytics() {
    if [[ ! -f "$ANALYTICS_FILE" ]]; then
        cat > "$ANALYTICS_FILE" << 'EOF'
{
  "created": "",
  "last_updated": "",
  "total_sessions": 0,
  "current_session": {
    "started": "",
    "commands_used": [],
    "tools_used": {},
    "duration_minutes": 0
  },
  "aggregate": {
    "command_usage": {},
    "tool_usage": {},
    "daily_activity": {},
    "common_workflows": []
  }
}
EOF
        # Set creation timestamp
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        local temp_file=$(mktemp)
        jq --arg ts "$timestamp" '.created = $ts | .last_updated = $ts' "$ANALYTICS_FILE" > "$temp_file" && mv "$temp_file" "$ANALYTICS_FILE"
    fi
}

# Function to extract command name from Task tool
extract_command_name() {
    local prompt="$1"

    # Check for slash command patterns
    if [[ "$prompt" == *"/test"* ]]; then
        echo "test"
    elif [[ "$prompt" == *"/test-coverage"* ]]; then
        echo "test-coverage"
    elif [[ "$prompt" == *"/code-review"* ]]; then
        echo "code-review"
    elif [[ "$prompt" == *"/full-context"* ]]; then
        echo "full-context"
    elif [[ "$prompt" == *"/refactor"* ]]; then
        echo "refactor"
    elif [[ "$prompt" == *"/update-docs"* ]]; then
        echo "update-docs"
    elif [[ "$prompt" == *"/create-docs"* ]]; then
        echo "create-docs"
    elif [[ "$prompt" == *"/gemini-consult"* ]]; then
        echo "gemini-consult"
    elif [[ "$prompt" == *"/handoff"* ]]; then
        echo "handoff"
    elif [[ "$prompt" == *"/dependency-audit"* ]]; then
        echo "dependency-audit"
    elif [[ "$prompt" == *"/performance"* ]]; then
        echo "performance"
    elif [[ "$prompt" == *"/debug"* ]]; then
        echo "debug"
    elif [[ "$prompt" == *"/migrate"* ]]; then
        echo "migrate"
    elif [[ "$prompt" == *"/scaffold"* ]]; then
        echo "scaffold"
    elif [[ "$prompt" == *"/api-docs"* ]]; then
        echo "api-docs"
    else
        echo "other"
    fi
}

# Function to record tool usage
record_tool_usage() {
    local tool_name="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local date_key=$(date -u +"%Y-%m-%d")

    initialize_analytics

    # Update analytics
    local temp_file=$(mktemp)
    jq --arg tool "$tool_name" --arg ts "$timestamp" --arg date "$date_key" '
        .last_updated = $ts |
        .aggregate.tool_usage[$tool] = ((.aggregate.tool_usage[$tool] // 0) + 1) |
        .aggregate.daily_activity[$date] = ((.aggregate.daily_activity[$date] // 0) + 1) |
        .current_session.tools_used[$tool] = ((.current_session.tools_used[$tool] // 0) + 1)
    ' "$ANALYTICS_FILE" > "$temp_file" && mv "$temp_file" "$ANALYTICS_FILE"

    log_event "tool_recorded" "$tool_name"
}

# Function to record command usage
record_command_usage() {
    local command_name="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    initialize_analytics

    # Update analytics
    local temp_file=$(mktemp)
    jq --arg cmd "$command_name" --arg ts "$timestamp" '
        .last_updated = $ts |
        .aggregate.command_usage[$cmd] = ((.aggregate.command_usage[$cmd] // 0) + 1) |
        .current_session.commands_used += [$cmd]
    ' "$ANALYTICS_FILE" > "$temp_file" && mv "$temp_file" "$ANALYTICS_FILE"

    log_event "command_recorded" "$command_name"
}

# Function to generate usage report
generate_report() {
    if [[ ! -f "$ANALYTICS_FILE" ]]; then
        echo "No analytics data available"
        return
    fi

    jq '
        {
            summary: {
                total_tool_invocations: (.aggregate.tool_usage | add // 0),
                total_command_uses: (.aggregate.command_usage | add // 0),
                days_active: (.aggregate.daily_activity | keys | length),
                most_used_tool: (
                    .aggregate.tool_usage | to_entries |
                    sort_by(.value) | reverse | .[0] // {key: "none", value: 0}
                ),
                most_used_command: (
                    .aggregate.command_usage | to_entries |
                    sort_by(.value) | reverse | .[0] // {key: "none", value: 0}
                )
            },
            tool_breakdown: .aggregate.tool_usage,
            command_breakdown: .aggregate.command_usage,
            recent_activity: (
                .aggregate.daily_activity | to_entries |
                sort_by(.key) | reverse | .[:7]
            )
        }
    ' "$ANALYTICS_FILE"
}

# Main function
main() {
    # Check if analytics is enabled
    if ! is_analytics_enabled; then
        # Pass through without recording
        echo '{"continue": true}'
        exit 0
    fi

    local tool_name=$(echo "$INPUT_JSON" | jq -r '.tool_name // ""')

    # Record tool usage
    if [[ -n "$tool_name" ]]; then
        record_tool_usage "$tool_name"

        # For Task tool, try to identify the command being used
        if [[ "$tool_name" == "Task" ]]; then
            local prompt=$(echo "$INPUT_JSON" | jq -r '.tool_input.prompt // ""')
            local command=$(extract_command_name "$prompt")
            if [[ "$command" != "other" ]]; then
                record_command_usage "$command"
            fi
        fi

        # For SlashCommand tool, record directly
        if [[ "$tool_name" == "SlashCommand" ]]; then
            local command=$(echo "$INPUT_JSON" | jq -r '.tool_input.command // ""' | cut -d' ' -f1 | tr -d '/')
            if [[ -n "$command" ]]; then
                record_command_usage "$command"
            fi
        fi
    fi

    # Always continue - this hook only records, never blocks
    echo '{"continue": true}'
    exit 0
}

# Check for report flag
if [[ "${1:-}" == "--report" ]]; then
    generate_report
    exit 0
fi

# Run main function
main
