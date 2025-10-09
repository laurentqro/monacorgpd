# Database Schema ERD

## Entity Relationship Diagram

```mermaid
erDiagram
    accounts ||--o{ questionnaires : "owns"
    accounts ||--o{ responses : "owns"
    accounts ||--o{ audit_sessions : "owns"
    users ||--o{ questionnaires : "creates"
    users ||--o{ responses : "responds"

    questionnaires ||--o{ sections : "contains"
    questionnaires ||--o{ responses : "has"

    sections ||--o{ questions : "contains"
    sections ||--o{ logic_rules : "targets"

    questions ||--o{ answer_choices : "has"
    questions ||--o{ logic_rules : "triggers"
    questions ||--o{ answers : "answered_by"

    responses ||--o{ answers : "contains"
    responses ||--|| audit_sessions : "generates"

    audit_sessions ||--o{ compliance_area_scores : "scored_by"

    compliance_areas ||--o{ compliance_area_scores : "scores"

    accounts {
        bigint id PK
        string name
        timestamp created_at
    }

    users {
        bigint id PK
        string email
        timestamp created_at
    }

    questionnaires {
        bigint id PK
        bigint account_id FK
        bigint creator_id FK
        string title
        text description
        string category
        enum status
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    sections {
        bigint id PK
        bigint questionnaire_id FK
        string title
        text description
        integer order_index
        timestamp created_at
        timestamp updated_at
    }

    questions {
        bigint id PK
        bigint section_id FK
        text question_text
        enum question_type
        text help_text
        integer order_index
        boolean is_required
        jsonb settings
        numeric weight
        timestamp created_at
        timestamp updated_at
    }

    answer_choices {
        bigint id PK
        bigint question_id FK
        text choice_text
        integer order_index
        numeric score
        timestamp created_at
    }

    logic_rules {
        bigint id PK
        bigint source_question_id FK
        bigint target_section_id FK
        enum condition_type
        jsonb condition_value
        enum action
        timestamp created_at
    }

    responses {
        bigint id PK
        bigint questionnaire_id FK
        bigint account_id FK
        bigint respondent_id FK
        enum status
        timestamp started_at
        timestamp completed_at
        timestamp created_at
        timestamp updated_at
    }

    answers {
        bigint id PK
        bigint response_id FK
        bigint question_id FK
        jsonb answer_value
        numeric calculated_score
        timestamp created_at
        timestamp updated_at
    }

    audit_sessions {
        bigint id PK
        bigint response_id FK
        bigint account_id FK
        numeric overall_score
        numeric max_possible_score
        string risk_level
        enum status
        timestamp created_at
        timestamp updated_at
    }

    compliance_areas {
        bigint id PK
        string name
        string code
        text description
        timestamp created_at
    }

    compliance_area_scores {
        bigint id PK
        bigint audit_session_id FK
        bigint compliance_area_id FK
        numeric score
        numeric max_score
        timestamp created_at
    }
```

## Table Groups

### Core Questionnaire Structure
- **questionnaires** - Main questionnaire definitions
- **sections** - Organizational sections within questionnaires
- **questions** - Individual questions
- **answer_choices** - Predefined choices for multiple/single choice questions
- **logic_rules** - Conditional branching logic

### Response Collection
- **responses** - User submission sessions
- **answers** - Individual question answers (JSONB for flexibility)

### Audit & Compliance
- **audit_sessions** - Compiled audit results with scoring
- **compliance_areas** - GDPR articles and principles (global reference data)
- **compliance_area_scores** - Detailed compliance breakdown per audit

### Multi-Tenancy
- **accounts** - Tenant isolation (from Jumpstart Pro)
- **users** - User accounts (from Jumpstart Pro)

## Key Design Decisions

1. **Multi-tenant Architecture**: All user data scoped to `account_id`
2. **Flexible Storage**: JSONB for `answer_value`, `settings`, `condition_value`
3. **Soft Deletes**: `deleted_at` on questionnaires only (MVP scope)
4. **Cascade Deletes**: Child records deleted when parent is removed
5. **Audit Trail**: `created_at`/`updated_at` timestamps with triggers
6. **Global Reference Data**: `compliance_areas` shared across all tenants

## Enum Types

- `questionnaire_status`: draft, published, archived
- `question_type`: single_choice, multiple_choice, text_short, text_long, yes_no, rating_scale
- `logic_condition_type`: equals, not_equals, contains, greater_than, less_than
- `logic_action`: show, hide, skip_to_section
- `response_status`: in_progress, completed
- `audit_status`: draft, completed
