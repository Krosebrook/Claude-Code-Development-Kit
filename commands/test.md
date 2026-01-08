# /test

*Multi-agent test generation and execution framework that creates comprehensive, maintainable tests with intelligent coverage analysis.*

## Core Philosophy

This command prioritizes **production-ready tests** that provide genuine safety nets:
- Tests that catch real bugs before they reach users
- Coverage of critical paths and edge cases
- Maintainable test code that evolves with your application
- Framework-appropriate testing patterns and best practices

### Test Categories

**Unit Tests**: Isolated component testing with mocked dependencies
**Integration Tests**: Component interaction and data flow verification
**Edge Case Tests**: Boundary conditions, error handling, and failure scenarios
**Regression Tests**: Prevent previously fixed bugs from recurring

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Understand Test Intent & Gather Context

#### Parse the Request
Analyze the natural language input to determine:
1. **What to test**: Parse file paths, component names, feature descriptions, or function names
2. **Test type**: Identify if specific test types are requested (unit, integration, e2e)
3. **Scope inference**: Intelligently determine the breadth of testing needed
4. **Generation vs Execution**: Determine if user wants to generate new tests, run existing tests, or both

Examples of intent parsing:
- "test the authentication flow" → Find auth-related code, generate/run comprehensive tests
- "generate unit tests for UserService" → Create unit tests for the specified service
- "run tests for the API routes" → Execute existing tests for API endpoints
- "test edge cases in payment processing" → Focus on boundary conditions and error paths

#### Read Relevant Documentation
Before allocating agents, **read the documentation** to understand:
1. Use `/docs/ai-context/docs-overview.md` to identify relevant docs
2. Read documentation related to the code being tested:
   - Architecture docs for understanding component relationships
   - API documentation for expected behaviors
   - Existing test files for patterns and conventions
   - CONTEXT.md files for feature-specific testing requirements
3. Identify the testing framework and conventions in use

This context ensures intelligent test generation based on actual project patterns.

### Step 2: Detect Testing Environment

#### Framework Detection
Automatically detect the testing ecosystem:

**JavaScript/TypeScript**:
- Jest, Vitest, Mocha, Jasmine
- Testing Library (React, Vue, Svelte)
- Playwright, Cypress for E2E

**Python**:
- pytest, unittest
- pytest-asyncio for async code
- pytest-cov for coverage

**Go**:
- Built-in testing package
- testify for assertions
- gomock for mocking

**Rust**:
- Built-in #[test] attribute
- tokio-test for async

**Other Languages**: Detect from config files (package.json, pyproject.toml, Cargo.toml, go.mod)

#### Test Configuration Discovery
Locate and analyze:
- Test configuration files
- Existing test directories and naming patterns
- Mock/fixture patterns in use
- Coverage configuration

### Step 3: Define Mandatory Test Coverage Areas

Every test generation MUST analyze these core areas, with depth determined by scope:

#### Mandatory Coverage Areas:

1. **Happy Path Testing**
   - Primary use cases that should always work
   - Expected input/output verification
   - Standard workflow validation

2. **Edge Cases & Boundaries**
   - Empty inputs, null values, undefined
   - Maximum/minimum values
   - Type coercion and validation boundaries
   - Unicode, special characters, injection attempts

3. **Error Handling**
   - Expected error conditions
   - Error message accuracy
   - Error recovery and cleanup
   - Async error propagation

4. **Integration Points**
   - API contract validation
   - Database interaction patterns
   - External service mocking
   - Event emission and handling

#### Dynamic Agent Allocation:

Based on test scope, allocate agents proportionally:

**Small Scope (single function or small component)**
- 1-2 agents covering core functionality and edge cases
- Direct test generation without extensive analysis

**Medium Scope (module or feature)**
- 2-3 agents with specialized focus
- Unit test generator + Integration test validator
- Coverage analyzer if requested

**Large Scope (system or subsystem)**
- 3-5 agents with comprehensive coverage
- Dedicated agents for each test type
- Cross-component integration testing

### Step 4: Execute Dynamic Multi-Agent Testing

**Before launching agents, pause and think deeply:**
- What are the critical paths that must be tested?
- What edge cases could cause production failures?
- What existing tests can we learn from?
- What testing patterns does this project use?

Generate and launch agents based on your thoughtful analysis:

```
For each dynamically generated agent:
  Task: "As [Agent_Role], [generate/analyze/execute] tests for [target_scope].

  MANDATORY COVERAGE CHECKLIST:
  ☐ Happy Path: [assigned aspects]
  ☐ Edge Cases: [assigned aspects]
  ☐ Error Handling: [assigned aspects]
  ☐ Integration Points: [assigned aspects]

  TESTING MANDATE:
  Generate tests that a senior developer would write - comprehensive but maintainable.

  Workflow:
  1. Review auto-loaded project context (CLAUDE.md, project-structure.md, docs-overview.md)
  2. Analyze existing test patterns in the codebase
  3. For framework questions, use:
     - mcp__context7__get-library-docs for testing library best practices
     - mcp__gemini__consult_gemini for complex testing strategy decisions
  4. Generate/analyze tests following project conventions
  5. Document test rationale:

     ## [Test_Category] by [Agent_Role]

     ### Test Files Generated
     - File: [path/to/test-file.test.ts]
     - Coverage: [what aspects this file tests]
     - Patterns Used: [describe patterns following project conventions]

     ### Test Cases
     | Test Name | Category | What It Validates |
     |-----------|----------|-------------------|
     | should_do_x | Happy Path | Verifies primary functionality |
     | handles_empty_input | Edge Case | Validates boundary condition |

     ### Mocking Strategy
     - [What is mocked and why]
     - [Mock patterns following project conventions]

     ### Edge Cases Covered
     - [Specific edge cases with rationale]

     ### Gaps Identified
     - [Areas that need additional testing]
     - [Complexity too high for automated generation]

  REMEMBER: Every test must add genuine value - no trivial assertions."
```

#### Parallel Execution Strategy:

**Launch all agents simultaneously** for maximum efficiency

### Step 5: Test Generation Execution

For test generation tasks:

#### File Structure
Follow project conventions for test file placement:
```
# Common patterns to detect and follow:
src/component.ts → src/component.test.ts (co-located)
src/component.ts → tests/component.test.ts (separate directory)
src/component.ts → __tests__/component.test.ts (Jest convention)
src/component.ts → src/component.spec.ts (.spec naming)
```

#### Test Template Structure

Generate tests following this structure (adapt to framework):

```typescript
/**
 * Test Suite: [ComponentName]
 * Generated by Claude Code Testing Framework
 *
 * Coverage:
 * - Happy path scenarios
 * - Edge cases and boundary conditions
 * - Error handling and recovery
 * - Integration with dependencies
 */

describe('[ComponentName]', () => {
  // Setup and teardown
  beforeEach(() => {
    // Reset state, setup mocks
  });

  afterEach(() => {
    // Cleanup
  });

  describe('Happy Path', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      // Act
      // Assert
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty input gracefully', () => {});
    it('should handle null/undefined values', () => {});
    it('should handle maximum boundary values', () => {});
  });

  describe('Error Handling', () => {
    it('should throw [ErrorType] when [invalid condition]', () => {});
    it('should recover gracefully from [failure scenario]', () => {});
  });

  describe('Integration', () => {
    it('should interact correctly with [dependency]', () => {});
  });
});
```

### Step 6: Test Execution

For test execution tasks:

#### Run Tests
Execute the appropriate test command based on detected framework:

```bash
# JavaScript/TypeScript
npm test / yarn test / pnpm test
npx jest [pattern]
npx vitest [pattern]

# Python
pytest [pattern]
python -m pytest [pattern]

# Go
go test ./...
go test -v [pattern]

# Rust
cargo test [pattern]
```

#### Capture Results
Parse and structure test output:
- Pass/fail counts
- Failed test details with stack traces
- Timing information
- Coverage summary if available

### Step 7: Synthesize and Present Results

After all sub-agents complete their analysis:

**ultrathink**

Activate maximum cognitive capabilities to:

1. **Consolidate Test Results**
   - Merge findings from all agents
   - Identify patterns in failures or gaps
   - Prioritize issues by severity

2. **Generate Coverage Report**
   - Calculate coverage metrics if tools available
   - Identify untested code paths
   - Recommend priority areas for additional tests

3. **Create Actionable Summary**
   ```markdown
   # Test Report

   **Target**: [scope description]
   **Date**: [current date]
   **Framework**: [detected framework]

   ## Summary
   - Tests Generated: [count]
   - Tests Executed: [count]
   - Passed: [count] | Failed: [count] | Skipped: [count]
   - Coverage: [percentage if available]

   ## Test Files
   | File | Tests | Status | Coverage |
   |------|-------|--------|----------|
   | [file] | [count] | [status] | [%] |

   ## Critical Findings

   ### Failed Tests
   - [test name]: [failure reason]
   - Fix: [suggested resolution]

   ### Coverage Gaps
   - [untested area]: [recommendation]

   ### Quality Issues
   - [issue]: [impact and fix]

   ## Generated Tests Summary
   [For generation tasks - list new test files with descriptions]

   ## Recommendations
   1. [Priority action items]
   2. [Additional test suggestions]
   ```

### Step 8: Interactive Follow-up

After presenting results, offer interactive follow-ups:
- "Would you like me to fix the failing tests?"
- "Should I generate additional tests for the coverage gaps?"
- "Do you want me to run the tests with coverage reporting?"
- "Should I create integration tests for the identified integration points?"
- "Would you like me to add these tests to a pre-commit hook?"

## Implementation Notes

1. **Use parallel Task execution** for all sub-agents to minimize testing time
2. **Follow existing test patterns** - analyze project's test files before generating
3. **Include file:line_number references** for easy navigation to issues
4. **Generate runnable tests** - all generated tests should pass on first run
5. **Respect project conventions** - naming, structure, assertion styles
6. **Use appropriate mocking** - don't over-mock, test real behavior when possible
7. **Consider test performance** - avoid slow tests, use appropriate isolation

## Error Handling

### Test Generation Issues
- **No test framework detected**: Suggest framework installation based on project type
- **Complex mocking required**: Document manual steps needed
- **Circular dependencies**: Identify and suggest refactoring

### Test Execution Issues
- **Configuration errors**: Provide setup guidance
- **Missing dependencies**: List required packages
- **Flaky tests**: Identify and suggest fixes

### Coverage Verification

Before presenting results, verify complete coverage:

```
☑ Happy Path Testing: [Covered by agents X, Y]
☑ Edge Case Testing: [Covered by agents Y, Z]
☑ Error Handling: [Covered by agents X, Z]
☑ Integration Testing: [Covered by agents W, X]
```

If any area lacks coverage, deploy additional focused agents.

## Framework-Specific Patterns

### Jest/Vitest
- Use `describe.each` for parameterized tests
- Leverage `beforeAll`/`afterAll` for expensive setup
- Use `jest.mock()` / `vi.mock()` for module mocking
- Prefer `toMatchSnapshot()` sparingly

### pytest
- Use fixtures for setup/teardown
- Leverage `@pytest.mark.parametrize` for data-driven tests
- Use `conftest.py` for shared fixtures
- Prefer `pytest.raises` for exception testing

### Go
- Use table-driven tests
- Leverage subtests with `t.Run()`
- Use testify for cleaner assertions
- Prefer interfaces for mockability
