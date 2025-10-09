# Database Design

## Overview

The Monaco RGPD database follows a normalized relational design optimized for multi-tenant SaaS operations with PostgreSQL as the backend.

## Design Principles

### 1. Multi-Tenancy
- **Pattern**: Shared database with `account_id` tenant isolation
- **Enforcement**: Foreign keys on all root tables pointing to `accounts`
- **Indexing**: Composite indexes include `account_id` for query optimization
- **Benefits**:
  - Cost-effective for multiple tenants
  - Easy backup and maintenance
  - Row-level isolation via Pundit policies

### 2. Data Integrity
- **CASCADE deletes**: Child records automatically removed with parent
- **Foreign key constraints**: Database-level referential integrity
- **NOT NULL constraints**: Required fields enforced at DB level
- **Unique constraints**: Prevent duplicate entries (e.g., response+question)

### 3. Performance Optimization
- **Composite indexes**: `(account_id, status)`, `(account_id, created_at)`
- **GIN indexes**: For JSONB column queries (settings, answer_value)
- **Partial indexes**: `WHERE deleted_at IS NULL` for soft deletes
- **Integer enums**: Fast comparisons, low storage overhead

### 4. Flexibility
- **JSONB columns**: Schema-less storage for dynamic data
  - `questions.settings` - Rating scales, validation rules
  - `answers.answer_value` - Polymorphic answer storage
  - `logic_rules.condition_value` - Flexible condition definitions
- **Benefits**:
  - No migrations for new question types
  - Store complex nested data
  - Query with PostgreSQL JSON operators

## Table Groups

### Core Questionnaire (Creation)
```
questionnaires → sections → questions → answer_choices
                                      ↓
                                 logic_rules
```
**Purpose**: Define questionnaire structure, questions, and conditional logic

### Response Collection (Submission)
```
responses → answers
```
**Purpose**: Store user submissions and individual answers

### Audit & Scoring (Analysis)
```
audit_sessions → compliance_area_scores
                        ↓
                 compliance_areas (reference)
```
**Purpose**: Calculate and store compliance audit results

## Enum Strategy

**Decision**: Use Rails integer-based enums, not PostgreSQL ENUM types

**Rationale**:
- ✅ Database-agnostic (works with MySQL, SQLite, PostgreSQL)
- ✅ Easy to add new values (model change only, no ALTER TYPE)
- ✅ Automatic Rails scopes and methods
- ✅ Smaller storage than strings (4 bytes for integer)
- ❌ PostgreSQL ENUMs require complex migrations to modify
- ❌ schema.rb can't properly represent custom ENUM types

**Implementation**:
```ruby
# Migration
t.integer :status, null: false, default: 0

# Model
enum status: { draft: 0, published: 1, archived: 2 }
```

## Soft Deletes

**Tables**: `questionnaires` only (MVP scope)

**Pattern**: `deleted_at` timestamp column
- NULL = active record
- NOT NULL = soft deleted

**Benefits**:
- Preserve historical data
- Prevent cascade deletion of responses
- Allow "undelete" functionality

**Index**: Partial index `WHERE deleted_at IS NULL` for active records

## Scaling Considerations

### Current Design (MVP)
- Single database
- Row-level multi-tenancy
- Suitable for: 100s-1000s of tenants

### Future Scaling Options
1. **Read replicas**: Separate read queries from writes
2. **Partitioning**: Partition large tables by `account_id`
3. **Sharding**: Move large tenants to dedicated databases
4. **Caching**: Redis/SolidCache for frequently accessed data

## Migration Strategy

Following Rails conventions:
- **One migration per table** (not monolithic)
- **No database triggers** (use ActiveRecord callbacks)
- **Standard DSL**: `t.references`, `t.timestamps`
- **Explicit defaults**: `default: 0` for enums

See `CLAUDE.md` for detailed migration guidelines.

## Related Documentation

- [Schema ERD](schema-erd.md) - Visual database diagram
- [Enum Mappings](../reference/enum-mappings.md) - Enum definitions
- [Complete Schema](../schemas/schema.sql) - Full PostgreSQL schema
