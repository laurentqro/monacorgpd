-- ============================================================================
-- MVP SCHEMA - GDPR Questionnaire App
-- ============================================================================
-- Simplified schema focused on core functionality:
--   - Questionnaires with sections and questions
--   - Conditional logic for dynamic forms
--   - Response tracking and scoring
--   - Basic audit results and recommendations
--
-- Assumes: accounts and users tables exist (from Jumpstart Pro)
-- PostgreSQL 14+
-- ============================================================================

-- ============================================================================
-- ENUM TYPES
-- ============================================================================
CREATE TYPE questionnaire_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE question_type AS ENUM ('single_choice', 'multiple_choice', 'text_short', 'text_long', 'yes_no', 'rating_scale');
CREATE TYPE logic_condition_type AS ENUM ('equals', 'not_equals', 'contains', 'greater_than', 'less_than');
CREATE TYPE logic_action AS ENUM ('show', 'hide', 'skip_to_section');
CREATE TYPE response_status AS ENUM ('in_progress', 'completed');
CREATE TYPE audit_status AS ENUM ('draft', 'completed');

-- ============================================================================
-- MAIN TABLES
-- ============================================================================
CREATE TABLE questionnaires (
    id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(100), -- 'gdpr', 'data_mapping', 'vendor_assessment'
    creator_id BIGINT REFERENCES users(id),
    status questionnaire_status NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE sections (
    id BIGSERIAL PRIMARY KEY,
    questionnaire_id BIGINT NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE questions (
    id BIGSERIAL PRIMARY KEY,
    section_id BIGINT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type question_type NOT NULL,
    help_text TEXT,
    order_index INTEGER NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT false,
    settings JSONB DEFAULT '{}', -- For rating scales, validation rules, etc.
    weight NUMERIC(5,2) DEFAULT 1.0, -- For scoring
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE answer_choices (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    choice_text TEXT NOT NULL,
    order_index INTEGER NOT NULL,
    score NUMERIC(5,2), -- Points for compliance scoring
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CONDITIONAL LOGIC
-- ============================================================================
CREATE TABLE logic_rules (
    id BIGSERIAL PRIMARY KEY,
    source_question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    target_section_id BIGINT REFERENCES sections(id) ON DELETE CASCADE,
    condition_type logic_condition_type NOT NULL,
    condition_value JSONB NOT NULL, -- {value, choice_id}
    action logic_action NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- RESPONSES & ANSWERS
-- ============================================================================
CREATE TABLE responses (
    id BIGSERIAL PRIMARY KEY,
    questionnaire_id BIGINT NOT NULL REFERENCES questionnaires(id) ON DELETE CASCADE,
    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    respondent_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    status response_status NOT NULL DEFAULT 'in_progress',
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE answers (
    id BIGSERIAL PRIMARY KEY,
    response_id BIGINT NOT NULL REFERENCES responses(id) ON DELETE CASCADE,
    question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    answer_value JSONB NOT NULL, -- {text: "..."} or {choice_ids: [1,2]}
    calculated_score NUMERIC(5,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(response_id, question_id)
);

-- ============================================================================
-- AUDIT RESULTS
-- ============================================================================
CREATE TABLE audit_sessions (
    id BIGSERIAL PRIMARY KEY,
    response_id BIGINT NOT NULL REFERENCES responses(id) ON DELETE CASCADE,
    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    overall_score NUMERIC(5,2),
    max_possible_score NUMERIC(5,2),
    risk_level VARCHAR(50), -- low, medium, high
    status audit_status NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compliance_areas (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100) UNIQUE, -- 'GDPR-ART-30', 'PRINCIPLE-LAWFULNESS'
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compliance_area_scores (
    id BIGSERIAL PRIMARY KEY,
    audit_session_id BIGINT NOT NULL REFERENCES audit_sessions(id) ON DELETE CASCADE,
    compliance_area_id BIGINT NOT NULL REFERENCES compliance_areas(id) ON DELETE CASCADE,
    score NUMERIC(5,2),
    max_score NUMERIC(5,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(audit_session_id, compliance_area_id)
);

-- ============================================================================
-- INDEXES (Optimized for multi-tenant queries)
-- ============================================================================
-- Questionnaires: tenant-scoped queries
CREATE INDEX idx_questionnaires_account_status ON questionnaires(account_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_questionnaires_account_created ON questionnaires(account_id, created_at DESC);

-- Sections & Questions: hierarchy navigation
CREATE INDEX idx_sections_questionnaire ON sections(questionnaire_id);
CREATE INDEX idx_sections_order ON sections(questionnaire_id, order_index);
CREATE INDEX idx_questions_section ON questions(section_id);
CREATE INDEX idx_questions_order ON questions(section_id, order_index);
CREATE INDEX idx_questions_settings_gin ON questions USING GIN(settings);

-- Answer choices
CREATE INDEX idx_answer_choices_question ON answer_choices(question_id);

-- Logic rules
CREATE INDEX idx_logic_rules_source ON logic_rules(source_question_id);
CREATE INDEX idx_logic_rules_target_section ON logic_rules(target_section_id);

-- Responses: tenant-scoped queries
CREATE INDEX idx_responses_account_status ON responses(account_id, status);
CREATE INDEX idx_responses_account_created ON responses(account_id, created_at DESC);
CREATE INDEX idx_responses_questionnaire ON responses(questionnaire_id);

-- Answers
CREATE INDEX idx_answers_response ON answers(response_id);
CREATE INDEX idx_answers_question ON answers(question_id);
CREATE INDEX idx_answers_value_gin ON answers USING GIN(answer_value);

-- Audit sessions: tenant-scoped queries
CREATE INDEX idx_audit_sessions_account_status ON audit_sessions(account_id, status);
CREATE INDEX idx_audit_sessions_account_created ON audit_sessions(account_id, created_at DESC);
CREATE INDEX idx_audit_sessions_response ON audit_sessions(response_id);

CREATE INDEX idx_compliance_area_scores_audit ON compliance_area_scores(audit_session_id);

-- ============================================================================
-- TRIGGERS
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_questionnaires_updated_at BEFORE UPDATE ON questionnaires
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sections_updated_at BEFORE UPDATE ON sections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_responses_updated_at BEFORE UPDATE ON responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_answers_updated_at BEFORE UPDATE ON answers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_audit_sessions_updated_at BEFORE UPDATE ON audit_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
