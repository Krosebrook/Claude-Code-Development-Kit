# /migrate

*Multi-agent migration framework for handling version upgrades, database schema changes, framework migrations, and codebase transformations with comprehensive impact analysis.*

## Core Philosophy

This command focuses on **safe, reversible migrations** that minimize risk:
- Analyze impact before making changes
- Create rollback strategies for every migration
- Preserve data integrity throughout
- Validate migrations at each step

### Migration Categories

**Dependency Upgrades**: Major version bumps, framework updates
**Database Migrations**: Schema changes, data transformations
**API Migrations**: Breaking changes, version transitions
**Architecture Migrations**: Structural refactoring, platform changes

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Understand Migration Scope

#### Parse the Request
Analyze the natural language input to determine:
1. **Migration type**: Package upgrade, database change, API version, etc.
2. **Source state**: Current version, schema, or structure
3. **Target state**: Desired end state
4. **Constraints**: Downtime tolerance, data sensitivity, rollback requirements

Examples of intent parsing:
- "upgrade to React 19" → Framework major version migration
- "add user roles to database" → Schema migration with data transformation
- "move from REST to GraphQL" → API architecture migration
- "migrate to TypeScript" → Language migration

### Step 2: Impact Analysis

**Migration Impact Analyst Agent**
```
Task: "Analyze the full impact of this migration.

Workflow:
1. Identify all affected components:
   - Direct dependencies
   - Indirect (transitive) dependencies
   - Configuration files
   - Test files
   - Documentation
2. Catalog breaking changes:
   - API changes
   - Behavior changes
   - Removed features
3. Estimate effort and risk
4. Identify external dependencies (CI/CD, monitoring, etc.)

Return comprehensive impact assessment."
```

### Step 3: Multi-Agent Migration Planning

Deploy specialized agents based on migration type:

**Breaking Change Analyzer Agent**
```
Task: "Analyze and catalog all breaking changes.

Workflow:
1. Review changelog/release notes for target version
2. Search codebase for affected patterns
3. For each breaking change:
   - Count occurrences in codebase
   - Assess complexity of fix
   - Check for automated codemods
4. Prioritize by risk and effort

Return breaking changes inventory with fix strategies."
```

**Data Migration Agent** (for database migrations)
```
Task: "Plan data migration strategy.

Workflow:
1. Analyze current schema
2. Define target schema
3. Plan transformation:
   - Additive changes (low risk)
   - Destructive changes (high risk)
   - Data transformation requirements
4. Design rollback strategy
5. Estimate migration duration

Return data migration plan with scripts."
```

**Code Transformation Agent**
```
Task: "Identify and plan code transformations.

Workflow:
1. Find all code patterns requiring changes
2. Categorize transformations:
   - Automated (codemod available)
   - Semi-automated (pattern-based)
   - Manual (requires understanding)
3. Create transformation rules
4. Generate example transformations

Return transformation plan with examples."
```

**Testing Strategy Agent**
```
Task: "Plan migration testing strategy.

Workflow:
1. Identify critical functionality to verify
2. Plan testing phases:
   - Pre-migration baseline
   - During migration validation
   - Post-migration verification
3. Design regression test suite
4. Plan performance comparison

Return testing strategy with checkpoints."
```

**Launch agents in parallel** for comprehensive planning.

### Step 4: Generate Migration Plan

**ultrathink**

Synthesize findings into comprehensive migration plan:

```markdown
# Migration Plan

**Migration**: [from] → [to]
**Date**: [current date]
**Estimated Effort**: [time estimate]
**Risk Level**: [Low/Medium/High/Critical]

## Executive Summary

### Scope
[Brief description of what's being migrated]

### Impact Assessment
| Category | Affected Items | Risk Level |
|----------|---------------|------------|
| Source Files | [X] files | [risk] |
| Dependencies | [X] packages | [risk] |
| Database | [X] tables | [risk] |
| Tests | [X] files | [risk] |
| Configuration | [X] files | [risk] |

### Effort Estimate
| Phase | Duration | Parallelizable |
|-------|----------|----------------|
| Preparation | [X] | No |
| Migration | [X] | Partially |
| Validation | [X] | Yes |
| Rollback Reserve | [X] | N/A |

---

## Pre-Migration Checklist

### Prerequisites
- [ ] Backup current state
- [ ] Notify stakeholders
- [ ] Prepare rollback scripts
- [ ] Verify test coverage
- [ ] Document current behavior

### Environment Preparation
```bash
# Backup commands
[backup commands]

# Verify current state
[verification commands]
```

---

## Migration Steps

### Phase 1: Non-Breaking Preparation
[Changes that can be made before the migration]

1. **[Step Name]**
   - Files affected: [list]
   - Changes: [description]
   ```[language]
   // Example change
   [code snippet]
   ```

### Phase 2: Core Migration
[The actual migration changes]

1. **[Step Name]**
   - Risk: [Low/Medium/High]
   - Duration: [estimate]
   - Rollback: [strategy]

   **Commands**:
   ```bash
   [migration commands]
   ```

   **Verification**:
   ```bash
   [verification commands]
   ```

### Phase 3: Post-Migration Cleanup
[Cleanup and optimization after migration]

---

## Breaking Changes

### [Breaking Change 1]

**What Changed**:
[Description]

**Affected Code**:
- [file:line] - [X] occurrences

**Migration Pattern**:
```[language]
// Before
[old code]

// After
[new code]
```

**Automated Fix Available**: [Yes/No]
```bash
# Codemod command if available
[command]
```

---

## Database Migration

### Schema Changes
```sql
-- Migration up
[SQL statements]

-- Migration down (rollback)
[SQL statements]
```

### Data Transformations
```sql
-- Data migration
[SQL statements]
```

### Estimated Duration
- Schema changes: [X] seconds
- Data migration: [X] minutes
- Index rebuilding: [X] minutes

---

## Rollback Strategy

### Triggers for Rollback
- [ ] Test failure rate > [X]%
- [ ] Error rate increase > [X]%
- [ ] Performance degradation > [X]%

### Rollback Steps
1. [Step 1]
2. [Step 2]

### Rollback Commands
```bash
[rollback commands]
```

---

## Testing Plan

### Pre-Migration Baseline
```bash
# Capture baseline metrics
[test commands]
```

### Migration Validation
```bash
# Run during migration
[validation commands]
```

### Post-Migration Verification
```bash
# Full test suite
[test commands]
```

### Performance Comparison
| Metric | Before | After | Acceptable |
|--------|--------|-------|------------|
| [metric] | [value] | [value] | [threshold] |

---

## Risk Mitigation

### Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [risk] | [L/M/H] | [L/M/H] | [strategy] |

### Contingency Plans
[Plans for if things go wrong]

---

## Timeline

| Time | Activity | Owner | Status |
|------|----------|-------|--------|
| T-1d | Backup | [team] | [ ] |
| T-2h | Final prep | [team] | [ ] |
| T+0 | Migration start | [team] | [ ] |
| T+Xh | Validation | [team] | [ ] |
| T+Xh | Complete | [team] | [ ] |
```

### Step 5: Interactive Follow-up

After presenting plan, offer:
- "Would you like me to execute this migration?"
- "Should I generate the migration scripts?"
- "Do you want me to create the rollback procedures?"
- "Should I run a dry-run first?"

## Migration Patterns

### Blue-Green Migration
For zero-downtime migrations:
1. Deploy new version alongside old
2. Switch traffic gradually
3. Roll back by switching back

### Feature Flags
For gradual rollout:
1. Add feature flag for new code
2. Enable for subset of users
3. Monitor and expand

### Strangler Pattern
For large migrations:
1. Build new alongside old
2. Route requests to new for specific features
3. Gradually migrate all features

## Error Handling

### Migration Failures
- Automatic rollback triggers
- State preservation
- Detailed error logging

### Data Inconsistencies
- Validation checkpoints
- Reconciliation scripts
- Manual review procedures
