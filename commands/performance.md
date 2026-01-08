# /performance

*Multi-agent performance profiling and optimization analysis that identifies bottlenecks, measures resource usage, and provides actionable optimization recommendations.*

## Core Philosophy

This command focuses on **measurable performance improvements** that impact user experience:
- Identify actual bottlenecks through profiling, not speculation
- Quantify performance impacts with real metrics
- Prioritize optimizations by user-visible impact
- Balance performance gains against code complexity

### Performance Categories

**Critical Path**: User-facing latency and responsiveness
**Resource Usage**: Memory, CPU, I/O consumption
**Scalability**: Performance under load
**Efficiency**: Algorithmic and architectural optimizations

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Understand Performance Context

#### Parse the Request
Analyze the natural language input to determine:
1. **Scope**: Specific endpoint, component, or entire application
2. **Symptoms**: Slow response, high memory, timeout issues
3. **Environment**: Development, staging, or production
4. **Baseline**: Any existing performance metrics or expectations

Examples of intent parsing:
- "API is slow" → Profile API endpoints, measure latency
- "memory leak in worker" → Analyze memory allocation patterns
- "database queries" → Focus on query performance
- "general performance audit" → Comprehensive analysis

### Step 2: Detect Performance Tools

Automatically detect available profiling tools:

**JavaScript/TypeScript**:
- Node.js built-in profiler
- Clinic.js (doctor, flame, bubbleprof)
- 0x for flamegraphs
- Chrome DevTools

**Python**:
- cProfile / profile
- py-spy
- memory_profiler
- line_profiler

**Go**:
- pprof (CPU, memory, goroutines)
- trace
- benchmark tests

**Rust**:
- cargo flamegraph
- perf
- Valgrind/Massif

**Database**:
- EXPLAIN ANALYZE
- Query plans
- Index analysis

### Step 3: Multi-Agent Performance Analysis

Deploy specialized agents:

**CPU Profiling Agent**
```
Task: "Analyze CPU usage and identify hot paths.

Workflow:
1. Run CPU profiler on target code
2. Generate flamegraph or hot path analysis
3. Identify:
   - Functions consuming >10% CPU time
   - Recursive or deeply nested calls
   - Synchronous blocking operations
   - Unnecessary computations
4. Calculate potential improvements

Return CPU profile analysis with optimization opportunities."
```

**Memory Analysis Agent**
```
Task: "Analyze memory allocation patterns and identify leaks.

Workflow:
1. Profile memory allocations
2. Identify:
   - Large allocations
   - Frequent small allocations (GC pressure)
   - Growing memory over time (potential leaks)
   - Unbounded data structures
3. Analyze object lifecycle
4. Check for circular references

Return memory profile with leak suspects and optimization recommendations."
```

**I/O and Latency Agent**
```
Task: "Analyze I/O operations and latency sources.

Workflow:
1. Profile database queries
2. Analyze external API calls
3. Identify:
   - N+1 query patterns
   - Missing indexes
   - Slow external dependencies
   - Synchronous I/O in hot paths
   - Missing caching opportunities
4. Measure latency distribution

Return I/O analysis with specific optimization targets."
```

**Algorithm Analysis Agent**
```
Task: "Review algorithmic efficiency of critical code paths.

Workflow:
1. Analyze complexity of key algorithms
2. Identify:
   - O(n²) or worse operations on large datasets
   - Inefficient data structure choices
   - Redundant computations
   - Missing early termination opportunities
3. Suggest algorithmic improvements

Return complexity analysis with refactoring recommendations."
```

**Launch agents in parallel** for comprehensive analysis.

### Step 4: Benchmark and Validate

For suggested optimizations:
1. Establish baseline measurements
2. Predict improvement potential
3. Identify any trade-offs

### Step 5: Generate Performance Report

```markdown
# Performance Analysis Report

**Target**: [scope description]
**Date**: [current date]
**Environment**: [environment details]

## Executive Summary

| Metric | Current | Target | Impact |
|--------|---------|--------|--------|
| Response Time (p50) | [X]ms | [Y]ms | [Z]% improvement |
| Response Time (p99) | [X]ms | [Y]ms | [Z]% improvement |
| Memory Usage | [X]MB | [Y]MB | [Z]% reduction |
| CPU Usage | [X]% | [Y]% | [Z]% reduction |

### Overall Assessment
[Brief summary of findings and recommended priorities]

---

## Critical Bottlenecks

### 1. [Bottleneck Name]

**Location**: [file:line_number]
**Impact**: [quantified impact - latency added, resources consumed]
**Root Cause**: [explanation]

**Current Code**:
```[language]
[problematic code snippet]
```

**Recommended Fix**:
```[language]
[optimized code snippet]
```

**Expected Improvement**: [quantified improvement]
**Effort**: [Low/Medium/High]
**Risk**: [Low/Medium/High]

---

## CPU Analysis

### Flamegraph Summary
[Description of hot paths identified]

### Top CPU Consumers

| Function | Time (%) | Calls | Avg Duration |
|----------|----------|-------|--------------|
| [func] | [%] | [count] | [time] |

### Optimization Opportunities

1. **[Function Name]** - [improvement description]
   - Current: [current behavior]
   - Suggested: [optimization]
   - Impact: [expected improvement]

---

## Memory Analysis

### Memory Profile Summary

| Category | Size | % of Total |
|----------|------|------------|
| Heap Used | [X]MB | [%] |
| External | [X]MB | [%] |
| Arrays/Buffers | [X]MB | [%] |

### Potential Memory Leaks
[List any suspected leaks with evidence]

### Allocation Hotspots
[High-frequency allocations causing GC pressure]

---

## I/O Analysis

### Database Queries

| Query Pattern | Calls | Avg Time | Total Time |
|---------------|-------|----------|------------|
| [pattern] | [N] | [Xms] | [Yms] |

### N+1 Query Patterns
[Identified N+1 patterns with fix recommendations]

### Missing Indexes
```sql
-- Recommended indexes
CREATE INDEX [index definition];
```

### Caching Opportunities
[Data that could benefit from caching]

---

## Algorithm Improvements

### Complexity Issues

| Code Location | Current | Optimal | Data Size Impact |
|---------------|---------|---------|------------------|
| [location] | O(n²) | O(n log n) | [impact at scale] |

---

## Recommended Action Plan

### Quick Wins (< 1 hour, high impact)
1. [Specific optimization]
2. [Specific optimization]

### Medium-term (1 day, significant impact)
1. [Optimization requiring more work]

### Long-term (requires planning)
1. [Architectural improvements]

---

## Benchmarking Commands

```bash
# Run performance benchmarks
[benchmark commands for the project]

# Profile specific endpoint
[profiling commands]

# Monitor memory usage
[memory monitoring commands]
```
```

### Step 6: Interactive Follow-up

After presenting results, offer:
- "Would you like me to implement the quick wins?"
- "Should I set up continuous performance monitoring?"
- "Do you want detailed profiling of a specific function?"
- "Should I create benchmark tests for the critical paths?"

## Implementation Notes

1. **Use non-invasive profiling** when possible
2. **Profile in production-like conditions** for accuracy
3. **Consider warm-up time** when benchmarking
4. **Account for variance** in measurements
5. **Preserve code readability** when optimizing
