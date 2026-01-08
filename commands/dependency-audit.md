# /dependency-audit

*Multi-agent security and health analysis of project dependencies, identifying vulnerabilities, outdated packages, and providing actionable upgrade recommendations.*

## Core Philosophy

This command focuses on **actionable security intelligence** that protects your application:
- Prioritize vulnerabilities by actual exploitation risk
- Provide clear upgrade paths with breaking change warnings
- Identify abandoned or unmaintained dependencies
- Balance security with stability concerns

### Audit Categories

**Critical Vulnerabilities**: Known exploits, CVEs with active attacks
**Security Warnings**: Potential vulnerabilities, unsafe patterns
**Outdated Dependencies**: Packages with newer versions available
**Maintenance Concerns**: Abandoned packages, deprecated APIs

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Detect Package Ecosystem

Automatically detect the dependency management system:

**JavaScript/TypeScript**:
- package.json + package-lock.json (npm)
- package.json + yarn.lock (Yarn)
- package.json + pnpm-lock.yaml (pnpm)

**Python**:
- requirements.txt
- Pipfile + Pipfile.lock (Pipenv)
- pyproject.toml + poetry.lock (Poetry)
- setup.py / setup.cfg

**Go**:
- go.mod + go.sum

**Rust**:
- Cargo.toml + Cargo.lock

**Ruby**:
- Gemfile + Gemfile.lock

**Java/Kotlin**:
- pom.xml (Maven)
- build.gradle / build.gradle.kts (Gradle)

### Step 2: Run Security Audits

Execute appropriate audit commands based on detected ecosystem:

#### JavaScript/TypeScript
```bash
npm audit --json
# or
yarn audit --json
# or
pnpm audit --json
```

#### Python
```bash
pip-audit --format json
# or
safety check --json
```

#### Go
```bash
govulncheck ./...
```

#### Rust
```bash
cargo audit --json
```

### Step 3: Multi-Agent Analysis

Deploy specialized agents for comprehensive analysis:

**Vulnerability Analyst Agent**
```
Task: "Analyze security vulnerabilities in project dependencies.

Workflow:
1. Parse security audit output
2. Research each vulnerability:
   - CVE details and severity scores
   - Exploitation likelihood
   - Affected versions and fix availability
3. Categorize by risk level:
   - Critical: Active exploits, no workaround
   - High: Known vulnerabilities, fix available
   - Medium: Theoretical risks, mitigations exist
   - Low: Minor issues, defense-in-depth concerns
4. Provide fix recommendations with breaking change warnings

Return prioritized vulnerability report with fix strategies."
```

**Dependency Health Agent**
```
Task: "Assess overall health of project dependencies.

Workflow:
1. Check last update dates for all dependencies
2. Identify maintenance status:
   - Actively maintained (updates within 6 months)
   - Slow maintenance (updates within 1-2 years)
   - Potentially abandoned (no updates > 2 years)
   - Deprecated (officially deprecated)
3. Check for:
   - Duplicate dependencies (same package, different versions)
   - Unused dependencies (if detectable)
   - Overly permissive version ranges
4. Assess license compatibility

Return health assessment with recommendations."
```

**Upgrade Path Agent**
```
Task: "Determine safe upgrade paths for outdated dependencies.

Workflow:
1. Identify outdated packages with available updates
2. For each outdated package:
   - Check semver compatibility
   - Review changelogs for breaking changes
   - Identify peer dependency conflicts
   - Check compatibility with project's language version
3. Categorize upgrades:
   - Safe: Patch/minor updates, no breaking changes
   - Moderate: Minor updates with some changes
   - Risky: Major updates requiring code changes
4. Create upgrade order considering dependency graph

Return upgrade plan with risk assessments."
```

**Launch agents in parallel** for comprehensive analysis.

### Step 4: Cross-Reference and Validate

After agents complete:

**ultrathink**

Synthesize findings to:
1. Eliminate false positives (development dependencies, unreachable code)
2. Identify transitive vulnerabilities (indirect dependencies)
3. Find conflicting upgrade recommendations
4. Prioritize based on actual project usage

### Step 5: Generate Audit Report

Present comprehensive report:

```markdown
# Dependency Audit Report

**Project**: [project name]
**Date**: [current date]
**Ecosystem**: [detected ecosystem]
**Total Dependencies**: [count]

## Executive Summary

| Category | Count | Action Required |
|----------|-------|-----------------|
| Critical Vulnerabilities | [X] | Immediate |
| High Severity | [X] | This Week |
| Outdated Packages | [X] | When Convenient |
| Health Concerns | [X] | Monitor |

### Risk Score: [High/Medium/Low]
[Brief overall assessment]

## Critical Vulnerabilities

### [Package Name] - [CVE-XXXX-XXXXX]

**Severity**: CRITICAL (CVSS: [score])
**Affected Version**: [version in use]
**Fixed Version**: [fixed version]
**Impact**: [description of potential impact]

**Exploitation**:
- Active exploits in the wild: [Yes/No]
- Attack vector: [description]
- Complexity: [Low/Medium/High]

**Fix**:
```bash
[upgrade command]
```

**Breaking Changes**: [Yes/No]
- [List any breaking changes if applicable]

**Workaround** (if upgrade not immediately possible):
[Temporary mitigation steps]

---

## High Severity Issues

[Similar format for each high severity issue]

---

## Outdated Dependencies

### Safe Upgrades (Recommended)

| Package | Current | Latest | Type | Risk |
|---------|---------|--------|------|------|
| [pkg] | [ver] | [ver] | patch | none |

### Breaking Upgrades (Review Required)

| Package | Current | Latest | Breaking Changes |
|---------|---------|--------|-----------------|
| [pkg] | [ver] | [ver] | [brief description] |

---

## Dependency Health

### Maintenance Concerns

| Package | Last Update | Status | Recommendation |
|---------|-------------|--------|----------------|
| [pkg] | [date] | [status] | [action] |

### License Summary

| License | Count | Compatibility |
|---------|-------|---------------|
| MIT | [X] | Compatible |
| Apache-2.0 | [X] | Compatible |
| GPL-3.0 | [X] | Review Required |

---

## Recommended Actions

### Immediate (Today)
1. [Critical fix steps]

### Short-term (This Week)
1. [High priority upgrades]

### Long-term (Next Sprint)
1. [Migration plans for abandoned packages]
2. [Major version upgrades]

---

## Upgrade Commands

### All Safe Upgrades
```bash
[combined upgrade command for all safe upgrades]
```

### Security Fixes Only
```bash
[upgrade commands for security fixes]
```
```

### Step 6: Interactive Follow-up

After presenting results, offer interactive follow-ups:
- "Would you like me to apply the safe upgrades?"
- "Should I research alternatives for the abandoned packages?"
- "Do you want detailed migration guides for the major upgrades?"
- "Should I set up automated security scanning in CI/CD?"

## Error Handling

### Audit Tool Issues
- **Tool not installed**: Provide installation commands
- **Network errors**: Retry or use cached data
- **Parse errors**: Fall back to basic analysis

### Edge Cases
- **No dependencies**: Report project as dependency-free
- **Lock file missing**: Warn about reproducibility
- **Private packages**: Note limited vulnerability data

## Implementation Notes

1. **Use native audit tools** for each ecosystem when available
2. **Cache vulnerability databases** for offline analysis
3. **Consider transitive dependencies** in upgrade paths
4. **Respect version constraints** when suggesting upgrades
5. **Check for security advisories** beyond CVE database
