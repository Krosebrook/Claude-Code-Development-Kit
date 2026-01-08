# /scaffold

*Multi-agent project scaffolding and template generation that creates boilerplate code, configuration, and structure following project conventions.*

## Core Philosophy

This command focuses on **consistent, convention-following scaffolding**:
- Match existing project patterns exactly
- Include all necessary boilerplate
- Generate tests alongside implementations
- Provide working code, not stubs

### Scaffold Categories

**Components**: UI components, services, modules
**Features**: Full feature implementations with all layers
**Infrastructure**: Configuration, CI/CD, deployment files
**Documentation**: CONTEXT.md files, API docs, specs

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Parse Scaffold Request

Analyze the natural language input to determine:
1. **Type**: Component, feature, service, module, configuration
2. **Name**: The name for the scaffolded element
3. **Location**: Where in the project structure
4. **Options**: Any specific requirements or variations

Examples of intent parsing:
- "scaffold UserProfile component" → React/Vue/Svelte component
- "scaffold payment service" → Backend service with API
- "create new API endpoint for orders" → Full API endpoint with validation
- "scaffold authentication feature" → Complete auth implementation

### Step 2: Detect Project Patterns

**Pattern Recognition Agent**
```
Task: "Analyze existing project patterns for scaffolding consistency.

Workflow:
1. Find similar existing elements in codebase
2. Extract patterns:
   - File structure and naming
   - Import/export patterns
   - Component/class structure
   - Test file organization
   - Documentation patterns
3. Identify required boilerplate
4. Note any framework-specific conventions

Return pattern guide for scaffolding."
```

### Step 3: Multi-Agent Scaffolding

Deploy specialized agents based on scaffold type:

**Structure Generator Agent**
```
Task: "Generate file structure for [scaffold type].

Workflow:
1. Based on detected patterns, create:
   - Main implementation file(s)
   - Test file(s)
   - Type definitions (if applicable)
   - Documentation (CONTEXT.md if needed)
2. Follow project directory conventions
3. Include all necessary imports
4. Create index files if pattern requires

Return file structure with paths."
```

**Implementation Generator Agent**
```
Task: "Generate implementation code following project patterns.

Workflow:
1. Analyze similar implementations in codebase
2. Generate code with:
   - Proper imports
   - Type definitions
   - Core functionality
   - Error handling
   - Logging (if project uses it)
3. Follow coding standards from CLAUDE.md
4. Add inline comments where helpful

Return implementation code."
```

**Test Generator Agent**
```
Task: "Generate test suite for scaffolded code.

Workflow:
1. Follow project test patterns
2. Generate tests for:
   - Happy path scenarios
   - Edge cases
   - Error handling
3. Include proper setup/teardown
4. Use project's mocking patterns

Return test code."
```

**Documentation Generator Agent**
```
Task: "Generate documentation for scaffolded code.

Workflow:
1. Create appropriate docs:
   - Inline documentation
   - CONTEXT.md if creating new directory
   - README if creating new module
2. Follow project documentation style
3. Include usage examples

Return documentation."
```

**Launch agents in parallel**.

### Step 4: Generate Scaffold

Present the complete scaffold:

```markdown
# Scaffold: [Name]

**Type**: [scaffold type]
**Created**: [date]

## Files Generated

```
[directory]/
├── [name].[ext]           # Main implementation
├── [name].test.[ext]      # Test suite
├── [name].types.[ext]     # Type definitions (if applicable)
├── index.[ext]            # Barrel export (if applicable)
└── CONTEXT.md             # Documentation (if new directory)
```

## Implementation

### [main file name]

```[language]
[full implementation code]
```

### [types file name] (if applicable)

```[language]
[type definitions]
```

### [index file name] (if barrel export)

```[language]
[export statements]
```

---

## Tests

### [test file name]

```[language]
[full test code]
```

---

## Documentation

### CONTEXT.md (if applicable)

```markdown
[documentation content]
```

---

## Integration

### Import Example
```[language]
import { [Name] } from '[path]';
```

### Usage Example
```[language]
[example usage code]
```

---

## Next Steps

1. [ ] Review generated code
2. [ ] Customize as needed
3. [ ] Run tests to verify
4. [ ] Update docs-overview.md if new directory
```

### Step 5: Interactive Follow-up

After presenting scaffold, offer:
- "Would you like me to create these files?"
- "Should I add this to the docs-overview.md?"
- "Do you want variations of any component?"
- "Should I generate additional test cases?"

## Scaffold Templates by Type

### React Component
```
components/
└── [Name]/
    ├── [Name].tsx        # Component implementation
    ├── [Name].test.tsx   # Tests
    ├── [Name].styles.ts  # Styles (if using CSS-in-JS)
    ├── [Name].types.ts   # Type definitions
    └── index.ts          # Barrel export
```

### Backend Service
```
services/
└── [name]/
    ├── [name].service.ts     # Service implementation
    ├── [name].service.test.ts # Tests
    ├── [name].types.ts       # Type definitions
    ├── [name].repository.ts  # Data access (if needed)
    └── index.ts              # Barrel export
```

### API Endpoint
```
api/
└── [resource]/
    ├── [resource].controller.ts  # Route handlers
    ├── [resource].service.ts     # Business logic
    ├── [resource].validation.ts  # Input validation
    ├── [resource].test.ts        # Tests
    └── index.ts                  # Route registration
```

### Full Feature
```
features/
└── [feature]/
    ├── components/          # UI components
    ├── hooks/              # Custom hooks
    ├── services/           # API calls
    ├── store/              # State management
    ├── types/              # Type definitions
    ├── utils/              # Utilities
    ├── [feature].test.ts   # Integration tests
    └── CONTEXT.md          # Documentation
```

## Framework Detection

Automatically detect and adapt to:

**Frontend Frameworks**:
- React (functional + hooks)
- Vue (Composition API / Options API)
- Svelte
- Angular

**Backend Frameworks**:
- Express
- Fastify
- NestJS
- Django
- FastAPI
- Go (standard library / Gin / Echo)

**Testing Frameworks**:
- Jest
- Vitest
- pytest
- Go testing

## Error Handling

### Pattern Not Found
- Fall back to common conventions
- Ask user for pattern preferences
- Suggest creating pattern first

### Naming Conflicts
- Check for existing files
- Suggest alternative names
- Ask for confirmation before overwriting
