# /test-coverage

*Deep coverage analysis that identifies untested code paths, measures test effectiveness, and provides actionable recommendations for improving test quality.*

## Core Philosophy

This command focuses on **meaningful coverage metrics** that indicate real test quality:
- Line coverage is a starting point, not a goal
- Branch coverage reveals logical complexity testing
- Function coverage shows API surface protection
- Critical path coverage matters more than percentage points

### Coverage Priorities

**Critical Paths**: Business logic, authentication, data mutations - must be near 100%
**Error Handlers**: Exception paths and recovery logic - often undertested
**Edge Cases**: Boundary conditions and unusual inputs - where bugs hide
**Integration Points**: API boundaries and external calls - contract verification

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Understand Coverage Analysis Scope

#### Parse the Request
Analyze the natural language input to determine:
1. **Scope**: Full project, specific directory, individual files, or feature area
2. **Depth**: Quick overview, detailed analysis, or comprehensive audit
3. **Focus**: Overall metrics, specific gaps, or trend analysis
4. **Thresholds**: Any specific coverage requirements mentioned

Examples of intent parsing:
- "analyze coverage for the payment module" → Focus on payment-related code
- "find untested code in auth" → Identify coverage gaps in authentication
- "full coverage report" → Complete project coverage analysis
- "coverage trends" → Compare current vs historical coverage

#### Read Relevant Documentation
Before analysis, **read the documentation** to understand:
1. Use `/docs/ai-context/docs-overview.md` to identify relevant docs
2. Read documentation related to the scope:
   - Test configuration for coverage tools
   - Critical path documentation for prioritization
   - Architecture docs for understanding component importance
3. Identify existing coverage configurations and thresholds

### Step 2: Detect Coverage Tools

#### Tool Detection
Automatically detect coverage ecosystem:

**JavaScript/TypeScript**:
- Istanbul/NYC (via Jest, Mocha)
- c8 (native V8 coverage)
- Vitest coverage

**Python**:
- pytest-cov / coverage.py
- Coverage configuration in pyproject.toml

**Go**:
- Built-in `go test -cover`
- go-coverage-report

**Rust**:
- cargo-tarpaulin
- cargo-llvm-cov

**Other Languages**: Detect from config files and tool installations

#### Configuration Analysis
Locate and analyze:
- Coverage configuration files
- Threshold settings
- Exclusion patterns
- Report output settings

### Step 3: Execute Coverage Analysis

#### Multi-Agent Strategy

Based on scope, deploy specialized agents:

**Coverage Metrics Agent**
```
Task: "Collect and analyze coverage metrics for [target_scope].

Workflow:
1. Run coverage collection command for detected framework
2. Parse coverage output (JSON/LCOV/XML format)
3. Calculate metrics:
   - Line coverage percentage
   - Branch coverage percentage
   - Function coverage percentage
   - Statement coverage

Return structured metrics with file-by-file breakdown."
```

**Gap Analysis Agent**
```
Task: "Identify critical coverage gaps in [target_scope].

Workflow:
1. Analyze uncovered code sections
2. Categorize gaps by severity:
   - Critical: Business logic, security, data handling
   - High: Error handlers, validation, integrations
   - Medium: Helper functions, utilities
   - Low: Logging, debugging, rarely-used paths
3. Identify patterns in uncovered code

Return prioritized list of coverage gaps with recommendations."
```

**Test Quality Agent**
```
Task: "Assess test quality beyond coverage numbers for [target_scope].

Workflow:
1. Analyze test assertions (not just execution)
2. Identify:
   - Weak assertions (trivial checks)
   - Missing edge case tests
   - Over-mocked tests (hiding real behavior)
   - Duplicated test logic
3. Evaluate test maintainability

Return quality assessment with specific improvement suggestions."
```

**Launch agents in parallel** for comprehensive analysis.

### Step 4: Coverage Execution Commands

Run appropriate coverage commands based on detected framework:

#### JavaScript/TypeScript (Jest)
```bash
npx jest --coverage --coverageReporters=json-summary --coverageReporters=text
```

#### JavaScript/TypeScript (Vitest)
```bash
npx vitest --coverage --reporter=json
```

#### Python (pytest)
```bash
pytest --cov=[module] --cov-report=json --cov-report=term-missing
```

#### Go
```bash
go test -cover -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

#### Rust
```bash
cargo tarpaulin --out json --out stdout
```

### Step 5: Analyze and Synthesize Results

**ultrathink**

Activate maximum cognitive capabilities to:

1. **Parse Coverage Data**
   - Extract metrics from coverage output
   - Calculate aggregated statistics
   - Identify trends if historical data available

2. **Categorize Uncovered Code**
   - Critical business logic
   - Error handling paths
   - Edge case branches
   - Integration boundaries

3. **Assess Risk Levels**
   - High risk: Uncovered critical paths
   - Medium risk: Missing edge case coverage
   - Low risk: Uncovered utility/helper code

4. **Generate Actionable Insights**
   - Specific files needing attention
   - Test generation priorities
   - Refactoring opportunities for testability

### Step 6: Generate Coverage Report

Present comprehensive report:

```markdown
# Coverage Analysis Report

**Scope**: [analyzed scope]
**Date**: [current date]
**Framework**: [detected framework]

## Executive Summary

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Line Coverage | [%] | [threshold] | [status] |
| Branch Coverage | [%] | [threshold] | [status] |
| Function Coverage | [%] | [threshold] | [status] |

### Overall Assessment
[Brief qualitative assessment of test coverage health]

## Coverage by Component

| Component | Lines | Branches | Functions | Risk Level |
|-----------|-------|----------|-----------|------------|
| [component] | [%] | [%] | [%] | [risk] |

## Critical Gaps

### High Priority (Immediate Attention)

#### [File/Component Name]
- **Uncovered Lines**: [line numbers]
- **Risk**: [why this matters]
- **Recommendation**: [specific action]
- **Suggested Test**:
  ```[language]
  // Example test to add
  it('should [behavior]', () => {
    // Test implementation
  });
  ```

### Medium Priority (Next Sprint)

[Similar format for medium priority items]

### Low Priority (Technical Debt)

[Brief list of low-priority gaps]

## Uncovered Code Analysis

### By Category
| Category | Uncovered Lines | % of Total Uncovered |
|----------|-----------------|---------------------|
| Error Handlers | [count] | [%] |
| Business Logic | [count] | [%] |
| Validation | [count] | [%] |
| Utilities | [count] | [%] |

### Untested Files
Files with 0% coverage that need attention:
- [file path]: [brief description of content]

## Test Quality Assessment

### Strengths
- [What's tested well]

### Weaknesses
- [Common gaps or anti-patterns]

### Anti-patterns Detected
- [List any testing anti-patterns found]

## Recommendations

### Immediate Actions
1. [Highest priority recommendation]
2. [Second priority]
3. [Third priority]

### Test Generation Priorities
| Priority | File/Component | Suggested Tests | Effort |
|----------|----------------|-----------------|--------|
| 1 | [path] | [description] | [estimate] |
| 2 | [path] | [description] | [estimate] |

### Process Improvements
- [Suggestions for CI/CD integration]
- [Coverage threshold recommendations]
- [Testing workflow improvements]

## Coverage Trends
[If historical data available]
- Previous coverage: [%]
- Current coverage: [%]
- Trend: [improving/declining/stable]

## Next Steps

1. Run `/test [high-priority-file]` to generate missing tests
2. Add coverage thresholds to CI/CD pipeline
3. Schedule coverage review for [component]
```

### Step 7: Interactive Follow-up

After presenting results, offer interactive follow-ups:
- "Would you like me to generate tests for the critical gaps?"
- "Should I set up coverage thresholds in your CI configuration?"
- "Do you want detailed analysis of any specific component?"
- "Should I create a coverage improvement plan?"
- "Would you like me to identify quick wins for coverage improvement?"

## Implementation Notes

1. **Run coverage tools in project root** to capture all files
2. **Parse machine-readable output** (JSON/LCOV) for accurate metrics
3. **Consider exclusion patterns** - some code legitimately doesn't need tests
4. **Focus on coverage quality** not just percentages
5. **Integrate with CI/CD** recommendations for continuous monitoring
6. **Historical tracking** suggests storing coverage over time

## Error Handling

### Coverage Tool Issues
- **Tool not installed**: Provide installation commands
- **Configuration missing**: Generate default configuration
- **Permissions errors**: Suggest fixes

### Data Parsing Issues
- **Unknown format**: Fall back to text parsing
- **Incomplete data**: Report partial results with caveats

### Edge Cases
- **No tests exist**: Recommend starting points for testing
- **100% coverage**: Focus on test quality and mutation testing
- **Coverage declining**: Identify recent changes causing gaps

## Coverage Threshold Recommendations

Based on project type:

| Project Type | Line | Branch | Function |
|--------------|------|--------|----------|
| Library/SDK | 90% | 85% | 95% |
| API/Backend | 80% | 75% | 85% |
| Frontend | 70% | 60% | 75% |
| CLI Tool | 85% | 80% | 90% |
| Data Pipeline | 75% | 70% | 80% |

These are starting points - adjust based on project criticality and team capacity.
