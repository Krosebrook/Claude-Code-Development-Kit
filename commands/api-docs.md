# /api-docs

*Multi-agent API documentation generator that analyzes code to produce OpenAPI/Swagger specifications, SDK documentation, and interactive API references.*

## Core Philosophy

This command focuses on **accurate, maintainable API documentation**:
- Extract documentation from actual code, not just comments
- Generate machine-readable specs (OpenAPI 3.x)
- Include realistic examples
- Keep documentation synchronized with implementation

### Documentation Categories

**OpenAPI/Swagger**: Machine-readable API specifications
**Reference Docs**: Endpoint-by-endpoint documentation
**SDK Documentation**: Client library usage guides
**Integration Guides**: How to integrate with the API

## Auto-Loaded Project Context

@/CLAUDE.md
@/docs/ai-context/project-structure.md
@/docs/ai-context/docs-overview.md

## Command Execution

User provided context: "$ARGUMENTS"

### Step 1: Detect API Framework

Automatically detect the API framework:

**JavaScript/TypeScript**:
- Express
- Fastify
- NestJS
- Hono
- Koa

**Python**:
- FastAPI (built-in OpenAPI)
- Django REST Framework
- Flask

**Go**:
- Standard library
- Gin
- Echo
- Fiber

**Rust**:
- Actix-web
- Axum
- Rocket

### Step 2: Analyze API Structure

**Route Discovery Agent**
```
Task: "Discover all API routes and their configurations.

Workflow:
1. Find route registration patterns
2. For each route extract:
   - HTTP method
   - Path (including parameters)
   - Middleware (auth, validation)
   - Handler function location
3. Build route tree

Return structured route inventory."
```

**Schema Extraction Agent**
```
Task: "Extract request/response schemas from code.

Workflow:
1. Find validation schemas (Zod, Joi, Pydantic, etc.)
2. Find type definitions for request/response
3. Extract:
   - Request body schemas
   - Query parameter schemas
   - Response schemas
   - Error response schemas
4. Infer types from handler implementations if needed

Return schema definitions in JSON Schema format."
```

**Example Generator Agent**
```
Task: "Generate realistic examples for API documentation.

Workflow:
1. Analyze schema constraints
2. Generate examples that:
   - Pass validation
   - Represent realistic data
   - Cover different scenarios
3. Include error response examples

Return example request/response pairs."
```

**Authentication Analyzer Agent**
```
Task: "Document authentication and authorization patterns.

Workflow:
1. Identify auth middleware
2. Document:
   - Authentication methods (JWT, API key, OAuth)
   - Authorization patterns (roles, scopes)
   - Token format and location
3. Generate auth examples

Return authentication documentation."
```

**Launch agents in parallel**.

### Step 3: Generate OpenAPI Specification

Synthesize findings into OpenAPI 3.x format:

```yaml
openapi: 3.1.0
info:
  title: [API Name]
  version: [version]
  description: [description]

servers:
  - url: [base URL]
    description: [environment]

paths:
  /[path]:
    [method]:
      summary: [summary]
      description: [description]
      operationId: [operationId]
      tags:
        - [tag]
      security:
        - [security requirement]
      parameters:
        - [parameters]
      requestBody:
        [request body schema]
      responses:
        [response schemas]

components:
  schemas:
    [reusable schemas]
  securitySchemes:
    [security definitions]
```

### Step 4: Generate Documentation

```markdown
# API Documentation

**Base URL**: `[base URL]`
**Version**: [version]
**Last Updated**: [date]

## Overview

[Brief API description]

## Authentication

### [Auth Method Name]

[Description of authentication method]

**Example**:
```bash
curl -H "Authorization: Bearer [token]" [endpoint]
```

---

## Endpoints

### [Tag/Category Name]

#### [Endpoint Name]

`[METHOD] /[path]`

[Description]

**Parameters**

| Name | In | Type | Required | Description |
|------|----|----|----------|-------------|
| [name] | [path/query/header] | [type] | [yes/no] | [description] |

**Request Body**

```json
{
  // [schema with example values]
}
```

**Responses**

| Status | Description |
|--------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized |

**Success Response** (200)
```json
{
  // [example response]
}
```

**Error Response** (400)
```json
{
  "error": "[error message]",
  "details": "[details]"
}
```

**Example**

```bash
curl -X [METHOD] '[base URL]/[path]' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer [token]' \
  -d '{
    // [example body]
  }'
```

---

## Schemas

### [Schema Name]

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| [field] | [type] | [yes/no] | [description] |

```json
{
  // [example]
}
```

---

## Error Codes

| Code | Name | Description |
|------|------|-------------|
| [code] | [name] | [description] |

---

## Rate Limiting

[Rate limiting policy if applicable]

---

## Changelog

[API version history]
```

### Step 5: Generate SDK Documentation (Optional)

If requested, generate SDK usage documentation:

```markdown
# SDK Documentation

## Installation

```bash
npm install [sdk-name]
# or
pip install [sdk-name]
```

## Quick Start

```[language]
// Initialize client
const client = new [Client]({
  apiKey: process.env.API_KEY
});

// Make request
const result = await client.[method]({
  // parameters
});
```

## API Reference

### [Class/Module Name]

#### [Method Name]

[Description]

**Parameters**:
- `[param]` ([type]): [description]

**Returns**: [return type]

**Example**:
```[language]
[code example]
```
```

### Step 6: Output Files

Generate documentation files:

```
docs/
├── api/
│   ├── openapi.yaml      # OpenAPI specification
│   ├── openapi.json      # JSON version
│   ├── README.md         # Human-readable docs
│   └── examples/
│       ├── [endpoint].sh # cURL examples
│       └── [endpoint].json # Request/response examples
```

### Step 7: Interactive Follow-up

After presenting documentation, offer:
- "Would you like me to create these documentation files?"
- "Should I generate a Postman collection?"
- "Do you want SDK examples in a specific language?"
- "Should I set up automatic doc generation in CI?"

## Integration Options

### Swagger UI Integration
```javascript
// Serve interactive documentation
app.use('/docs', swaggerUi.serve, swaggerUi.setup(openApiSpec));
```

### Redoc Integration
```html
<redoc spec-url='./openapi.yaml'></redoc>
```

### Postman Collection
Generate importable Postman collection from OpenAPI spec.

## Error Handling

### Incomplete Information
- Generate with TODOs for missing info
- Flag endpoints needing manual documentation
- Suggest improvements

### Framework Not Detected
- Fall back to manual specification
- Use generic patterns
- Ask for framework clarification
