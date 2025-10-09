# Monaco RGPD Documentation

This directory contains comprehensive documentation for the **MonacoRGPD** compliance questionnaire system, built to support organizations complying with **Monaco's Law No. 1.565** (December 3, 2024) on the protection of personal data.

## Monaco Context

- **Law 1.565**: Monaco's data protection law (effective December 3, 2024)
- **APDP**: Autorité de Protection des Données Personnelles - Monaco's data protection authority
- **Convention 108+**: International data protection treaty ratified by Monaco (March 6, 2025)
- **RGPD Alignment**: Monaco's law aligns with EU GDPR principles while addressing Monaco-specific requirements

## Directory Structure

### 🇲🇨 loi-1565/
Monaco's Data Protection Law (10 chapters)
- Complete text of Law No. 1.565 in French
- Chapters I-X covering all aspects of data protection
- Official legal framework for compliance

### 🏛️ apdp/
APDP (Monaco DPA) Guidance and Resources
- Official guidance documents from APDP
- Practical guides for compliance
- Template letters and forms
- Sector-specific guidance

### 📐 architecture/
System design and database documentation
- **schema-erd.md** - Entity Relationship Diagram (Mermaid format)
- **separation-strategy.md** - How GDPR code is separated from Jumpstart Pro
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
  - Monaco Law 1.565 context and APDP requirements
  - Rails conventions and best practices
  - Multi-tenancy patterns
  - Enum and migration guidelines

## For LLMs/AI Assistants

This documentation structure is optimized for both human developers and AI assistants:

1. **Understand Monaco context**: Read `loi-1565/` and `apdp/README.md` for legal framework
2. **Start with** `CLAUDE.md` (in project root) for conventions and patterns
3. **Refer to** `architecture/schema-erd.md` for database relationships
4. **Refer to** `architecture/separation-strategy.md` for namespacing approach
5. **Follow** `implementation/implementation-plan.md` for step-by-step guidance
6. **Reference** `reference/enum-mappings.md` when working with models
7. **Consult** `schemas/schema.sql` for complete database specifications

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
