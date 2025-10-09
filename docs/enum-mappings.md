# Enum Mappings for Models

This document defines the integer-to-string mappings for all enums in the application. These will be defined in the respective models using `enum` method.

## Questionnaire Status
**Column:** `questionnaires.status` (integer, default: 0)

```ruby
enum status: {
  draft: 0,
  published: 1,
  archived: 2
}
```

**Usage:**
- `questionnaire.draft!` - sets status to draft
- `questionnaire.draft?` - checks if status is draft
- `Questionnaire.draft` - scope for all draft questionnaires

---

## Question Type
**Column:** `questions.question_type` (integer)

```ruby
enum question_type: {
  single_choice: 0,
  multiple_choice: 1,
  text_short: 2,
  text_long: 3,
  yes_no: 4,
  rating_scale: 5
}
```

**Usage:**
- `question.single_choice!` - sets type to single_choice
- `question.single_choice?` - checks if type is single_choice
- `Question.single_choice` - scope for all single_choice questions

---

## Logic Condition Type
**Column:** `logic_rules.condition_type` (integer)

```ruby
enum condition_type: {
  equals: 0,
  not_equals: 1,
  contains: 2,
  greater_than: 3,
  less_than: 4
}
```

**Usage:**
- `logic_rule.equals!` - sets condition to equals
- `logic_rule.equals?` - checks if condition is equals
- `LogicRule.equals` - scope for all equals conditions

---

## Logic Action
**Column:** `logic_rules.action` (integer)

```ruby
enum action: {
  show: 0,
  hide: 1,
  skip_to_section: 2
}
```

**Usage:**
- `logic_rule.show!` - sets action to show
- `logic_rule.show?` - checks if action is show
- `LogicRule.show` - scope for all show actions

---

## Response Status
**Column:** `responses.status` (integer, default: 0)

```ruby
enum status: {
  in_progress: 0,
  completed: 1
}
```

**Usage:**
- `response.in_progress!` - sets status to in_progress
- `response.in_progress?` - checks if status is in_progress
- `Response.in_progress` - scope for all in_progress responses

---

## Audit Status
**Column:** `audit_sessions.status` (integer, default: 0)

```ruby
enum status: {
  draft: 0,
  completed: 1
}
```

**Usage:**
- `audit_session.draft!` - sets status to draft
- `audit_session.draft?` - checks if status is draft
- `AuditSession.draft` - scope for all draft audit_sessions

---

## Benefits of Integer-Based Enums

1. **Database Agnostic** - Works with any database (PostgreSQL, MySQL, SQLite)
2. **Easy to Modify** - Add new values without ALTER TYPE statements
3. **Automatic Methods** - Rails generates query methods, scopes, and bang methods
4. **Performance** - Integer comparisons are fast and take less storage than strings
5. **Rails Conventions** - Standard Rails approach, familiar to all Rails developers

## Best Practices

- Always set a default value (usually 0) in migrations
- Define enums in models with explicit integer mappings
- Use `_prefix` or `_suffix` if enum names conflict with existing methods
- Document enum values in model comments for clarity
