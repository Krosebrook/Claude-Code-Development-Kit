# Testing Context Template

*Template for documenting testing patterns and conventions. Copy this to your `tests/CONTEXT.md` or component test directories.*

## Testing Framework

**Framework**: [Jest / Vitest / pytest / Go test / Cargo test / Other]
**Coverage Tool**: [Istanbul / c8 / pytest-cov / go cover / tarpaulin]
**Mocking Library**: [jest.mock / vi.mock / unittest.mock / testify / mockall]

## Directory Structure

```
tests/                      # Or __tests__/, test/, specs/
├── unit/                   # Unit tests
│   ├── services/          # Service layer tests
│   ├── utils/             # Utility function tests
│   └── models/            # Data model tests
├── integration/           # Integration tests
│   ├── api/               # API endpoint tests
│   └── database/          # Database integration tests
├── e2e/                   # End-to-end tests
├── fixtures/              # Test data and fixtures
├── mocks/                 # Mock implementations
└── helpers/               # Test utility functions
```

## Naming Conventions

| Category | Pattern | Example |
|----------|---------|---------|
| Unit test files | `{module}.test.{ext}` | `userService.test.ts` |
| Integration tests | `{module}.integration.test.{ext}` | `api.integration.test.ts` |
| E2E tests | `{feature}.e2e.test.{ext}` | `checkout.e2e.test.ts` |
| Test descriptions | `should {behavior} when {condition}` | `should return user when valid ID` |

## Test Categories

### Unit Tests
- **Purpose**: Test individual functions/methods in isolation
- **Dependencies**: All external dependencies mocked
- **Speed**: Fast (< 100ms per test)
- **Coverage Target**: 85%+

### Integration Tests
- **Purpose**: Test component interactions
- **Dependencies**: Real implementations where possible
- **Speed**: Medium (< 1s per test)
- **Coverage Target**: 70%+

### End-to-End Tests
- **Purpose**: Test complete user workflows
- **Dependencies**: Full system (may use test doubles for external services)
- **Speed**: Slow (may take seconds)
- **Coverage Target**: Critical paths only

## Testing Patterns

### Setup and Teardown

```[language]
// Example pattern - adapt to your framework
beforeEach(() => {
  // Reset state
  // Setup mocks
  // Initialize test data
});

afterEach(() => {
  // Cleanup
  // Reset mocks
  // Clear test data
});
```

### Mocking Strategy

**What to Mock**:
- External HTTP calls
- Database connections
- File system operations
- Time-dependent functions
- Third-party services

**What NOT to Mock**:
- Internal utility functions
- Data transformation logic
- Business rules
- The code under test

### Data-Driven Tests

```[language]
// Example: Parameterized testing
test.each([
  { input: '', expected: false },
  { input: 'valid', expected: true },
  { input: null, expected: false },
])('validates input: $input -> $expected', ({ input, expected }) => {
  expect(validate(input)).toBe(expected);
});
```

## Coverage Requirements

| Metric | Minimum | Target | Critical Paths |
|--------|---------|--------|----------------|
| Lines | 70% | 85% | 95% |
| Branches | 65% | 80% | 90% |
| Functions | 75% | 90% | 100% |

### Excluded from Coverage
- Configuration files
- Type definitions
- Generated code
- Development utilities

## Test Commands

```bash
# Run all tests
[npm test / pytest / go test ./... / cargo test]

# Run with coverage
[npm test -- --coverage / pytest --cov / go test -cover ./...]

# Run specific tests
[npm test -- --testPathPattern=auth / pytest -k auth / go test ./auth/...]

# Watch mode
[npm test -- --watch / pytest-watch / cargo watch -x test]
```

## Fixtures and Test Data

**Location**: `tests/fixtures/` or `__fixtures__/`

**Patterns**:
- Factory functions for dynamic data
- JSON files for static fixtures
- Builder pattern for complex objects

```[language]
// Example: Test data factory
const createUser = (overrides = {}) => ({
  id: 'test-id',
  name: 'Test User',
  email: 'test@example.com',
  ...overrides
});
```

## Common Test Scenarios

### Happy Path
- Valid input with expected output
- Successful operations
- Normal user workflows

### Edge Cases
- Empty inputs
- Boundary values (0, -1, MAX)
- Unicode and special characters
- Large datasets

### Error Handling
- Invalid inputs
- Network failures
- Timeout scenarios
- Permission errors

### Security
- Authentication required
- Authorization checks
- Input validation
- XSS prevention

## CI/CD Integration

**Test Stage**:
```yaml
test:
  script:
    - [test command]
  coverage: '/Coverage: \d+\.\d+%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: [format]
        path: coverage/[report-file]
```

## Troubleshooting

### Flaky Tests
- Avoid time-dependent assertions
- Use proper async/await handling
- Ensure test isolation
- Reset global state

### Slow Tests
- Mock expensive operations
- Use database transactions (rollback)
- Parallelize when possible
- Use `-short` flags for quick runs

### Coverage Gaps
- Use `/test-coverage` command for analysis
- Focus on critical paths first
- Don't chase 100% - aim for meaningful coverage

---

*Customize this template for your project's specific testing requirements and conventions.*
