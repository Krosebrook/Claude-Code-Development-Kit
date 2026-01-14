# /debug

*Multi-agent systematic debugging framework that traces errors to root causes, analyzes stack traces, and provides targeted fixes for complex bugs.*

## Core Philosophy

This command focuses on **systematic problem-solving** rather than guesswork:
- Reproduce the issue reliably before attempting fixes
- Trace execution paths to find root causes
- Consider all contributing factors
- Validate fixes don't introduce regressions

### Debug Categories

**Runtime Errors**: Exceptions, crashes, undefined behavior
**Logic Errors**: Incorrect outputs, unexpected state
**Integration Issues**: API failures, service communication
**Performance Bugs**: Timeouts, resource exhaustion

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Gather Bug Context

#### Parse the Bug Report
Extract from user input:
1. **Symptoms**: What's happening vs what's expected
2. **Error messages**: Stack traces, logs, error codes
3. **Reproduction steps**: How to trigger the issue
4. **Environment**: Versions, configurations, circumstances
5. **Frequency**: Always, intermittent, specific conditions

Examples of intent parsing:
- "TypeError in checkout" → Locate type mismatch, trace data flow
- "API returns 500" → Analyze server-side error handling
- "race condition in sync" → Investigate concurrent access
- "memory leak after login" → Profile memory over time

### Step 2: Analyze Error Context

If error message/stack trace provided:

**Stack Trace Parser**
```
Task: "Analyze the provided stack trace to understand error context.

Workflow:
1. Parse stack trace structure
2. Identify:
   - Error type and message
   - Origin point (where error was thrown)
   - Call chain (how we got there)
   - Relevant variable values if logged
3. Map to source files in codebase
4. Check for common patterns in error type

Return structured analysis of error location and context."
```

### Step 3: Multi-Agent Investigation

Deploy specialized agents based on bug type:

**Code Flow Tracer Agent**
```
Task: "Trace execution flow leading to the bug.

Workflow:
1. Start from error location
2. Trace backwards through:
   - Function call chain
   - Data transformations
   - State modifications
   - External inputs
3. Identify where behavior diverges from expected
4. Map data flow through the path

Return execution trace with annotated decision points."
```

**State Analysis Agent**
```
Task: "Analyze state management and data flow for anomalies.

Workflow:
1. Identify all state involved in the bug
2. Check for:
   - Invalid state transitions
   - Race conditions in state updates
   - Missing state initialization
   - State mutation in unexpected places
3. Trace state changes through the bug scenario

Return state analysis with potential corruption points."
```

**Environment Agent**
```
Task: "Investigate environmental factors contributing to the bug.

Workflow:
1. Check configuration handling
2. Identify:
   - Environment-specific code paths
   - Missing or incorrect config values
   - Version mismatches
   - External dependency issues
3. Compare working vs non-working environments

Return environmental factors analysis."
```

**Pattern Recognition Agent**
```
Task: "Identify common bug patterns that match this issue.

Workflow:
1. Compare symptoms against known bug patterns:
   - Null reference patterns
   - Off-by-one errors
   - Async/await misuse
   - Resource cleanup failures
   - Type coercion issues
2. Check for similar issues in project history
3. Search for framework-specific gotchas

Return pattern matching analysis with likely causes."
```

**Launch agents in parallel** based on bug characteristics.

### Step 4: Root Cause Analysis

**ultrathink**

Synthesize agent findings to:
1. Eliminate red herrings
2. Identify the true root cause
3. Understand why the bug wasn't caught earlier
4. Consider if the bug could exist elsewhere

### Step 5: Develop Fix Strategy

For each potential root cause:
1. Propose minimal fix
2. Consider edge cases
3. Identify regression risks
4. Plan validation approach

### Step 6: Generate Debug Report

```markdown
# Debug Analysis Report

**Issue**: [brief description]
**Date**: [current date]
**Severity**: [Critical/High/Medium/Low]
**Status**: [Root cause identified / Needs more info / Fixed]

## Bug Summary

### Symptoms
[What's happening]

### Expected Behavior
[What should happen]

### Reproduction
1. [Step 1]
2. [Step 2]
3. [Expected: X, Actual: Y]

---

## Root Cause Analysis

### Primary Cause
**Location**: [file:line_number]
**Type**: [error category]

**Explanation**:
[Detailed explanation of why the bug occurs]

### Contributing Factors
1. [Factor 1 and its role]
2. [Factor 2 and its role]

### Evidence
```[language]
// The problematic code
[code snippet with issue highlighted]
```

**Why this fails**:
[Technical explanation]

---

## Execution Trace

```
[Simplified trace showing how we reached the bug]
1. Entry point: [function]
2. Data received: [values]
3. Decision at line X: [branch taken]
4. State modification: [what changed]
5. Bug triggered: [why it failed]
```

---

## Proposed Fix

### Option 1: [Fix Name] (Recommended)

**Changes Required**:

**File**: [file:line_number]
```[language]
// Before
[original code]

// After
[fixed code]
```

**Rationale**:
[Why this fix addresses the root cause]

**Edge Cases Handled**:
- [Edge case 1]
- [Edge case 2]

**Regression Risk**: [Low/Medium/High]

### Option 2: [Alternative Fix Name]

[Similar format for alternative approach if applicable]

---

## Validation Plan

### Unit Tests to Add
```[language]
// Test case for the bug scenario
[test code]
```

### Manual Verification
1. [Step to verify fix]
2. [Step to verify no regression]

---

## Prevention Recommendations

### Immediate
1. [Quick improvement to prevent similar bugs]

### Long-term
1. [Architectural or process improvement]

---

## Related Code to Review

The same pattern might exist in:
- [file:line_number] - [brief description]
- [file:line_number] - [brief description]
```

### Step 7: Interactive Follow-up

After presenting analysis, offer:
- "Would you like me to implement the fix?"
- "Should I add the validation tests?"
- "Do you want me to check for similar bugs elsewhere?"
- "Should I set up logging to catch this pattern early?"

## Debugging Techniques

### Bisection
When bug was introduced by a change:
```bash
git bisect start
git bisect bad HEAD
git bisect good [last-known-good-commit]
```

### Logging Enhancement
Temporary logging for investigation:
```[language]
// Add strategic logging
console.log('[DEBUG] state at critical point:', state);
```

### Isolation
Reproduce in minimal environment:
- Create minimal reproduction case
- Eliminate irrelevant dependencies
- Test with known inputs

## Error Handling

### Insufficient Information
- Request specific error messages
- Ask for reproduction steps
- Suggest adding diagnostic logging

### Intermittent Bugs
- Investigate timing/race conditions
- Check for external dependencies
- Analyze patterns in occurrence

### Environment-Specific
- Compare configurations
- Check for version differences
- Investigate platform-specific behavior
