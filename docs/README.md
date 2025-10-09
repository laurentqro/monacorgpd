# Monaco RGPD Documentation

This directory contains comprehensive documentation for the Monaco RGPD GDPR questionnaire system.

## Directory Structure

### 📐 architecture/
System design and database documentation
- **schema-erd.md** - Entity Relationship Diagram (Mermaid format)
  - Visual representation of all database tables and relationships
  - Cardinality and foreign key constraints
  - Multi-tenant architecture patterns

### 🚀 implementation/
Implementation guides and plans
- **implementation-plan.md** - Complete 11-phase implementation roadmap
  - Detailed step-by-step instructions
  - Code examples for each phase
  - 4-week timeline with milestones

### 📚 reference/
Technical reference documentation
- **enum-mappings.md** - Rails enum definitions
  - All integer-to-string enum mappings
  - Usage examples and best practices
  - Benefits of integer-based enums

### 🗄️ schemas/
Raw database schemas
- **schema.sql** - Complete PostgreSQL schema
  - Table definitions with comments
  - Indexes and constraints
  - Enum types and triggers documentation

## Root Documentation Files

- **CLAUDE.md** - Project guidelines for Claude Code (AI assistant)
  - Rails conventions and best practices
  - Multi-tenancy patterns
  - Enum and migration guidelines

## For LLMs/AI Assistants

This documentation structure is optimized for both human developers and AI assistants:

1. **Start with** `CLAUDE.md` (in project root) for conventions and patterns
2. **Refer to** `architecture/schema-erd.md` for database relationships
3. **Follow** `implementation/implementation-plan.md` for step-by-step guidance
4. **Reference** `reference/enum-mappings.md` when working with models
5. **Consult** `schemas/schema.sql` for complete database specifications

## Quick Navigation

| What you need | Where to find it |
|---------------|------------------|
| Database relationships | `architecture/schema-erd.md` |
| Implementation steps | `implementation/implementation-plan.md` |
| Enum definitions | `reference/enum-mappings.md` |
| Complete SQL schema | `schemas/schema.sql` |
| Rails conventions | `../CLAUDE.md` |

## Contributing

When adding documentation:
- Place architecture docs in `architecture/`
- Place how-to guides in `implementation/`
- Place reference material in `reference/`
- Place raw schemas/configs in `schemas/`
- Keep docs concise and focused
- Include examples where helpful
