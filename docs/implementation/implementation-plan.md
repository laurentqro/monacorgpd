# Monaco RGPD Questionnaire Application - Implementation Plan

## Overview
This document outlines the step-by-step implementation plan for building a multi-tenant data protection compliance questionnaire application for **Monaco's Law No. 1.565** using Ruby on Rails 8, Svelte 5, and Inertia.js.

### Monaco Context
- **Law 1.565**: Monaco's data protection law (December 3, 2024)
- **APDP**: Autorité de Protection des Données Personnelles (Monaco's DPA)
- **RGPD Alignment**: Monaco law aligns with EU GDPR principles
- **Compliance Areas**: Based on GDPR principles (Lawfulness, Purpose Limitation, etc.) and key articles (30, 32, 35, 37)

## Prerequisites
- Jumpstart Pro Rails installed and configured
- PostgreSQL database
- Node.js and npm/yarn
- Svelte 5 and Inertia.js configured (already done per CLAUDE.md)

---

## Phase 1: Database Setup

### Step 1.1: Create Database Migrations

```bash
# Generate migrations for core tables
bin/rails generate migration CreateQuestionnaireTables
```

**Migration file content:**
- Follow Rails conventions
- Create tables in dependency order
- Add indexes last

**Files to create:**
- `db/migrate/YYYYMMDDHHMMSS_create_questionnaire_tables.rb`

**Validation:**
```bash
bin/rails db:migrate
bin/rails db:migrate:status
```

---

## Phase 2: Models and Business Logic

### Step 2.1: Generate Base Models

```bash
# Generate models (skip migrations since we already created them)
bin/rails generate model Questionnaire --skip-migration
bin/rails generate model Section --skip-migration
bin/rails generate model Question --skip-migration
bin/rails generate model AnswerChoice --skip-migration
bin/rails generate model LogicRule --skip-migration
bin/rails generate model Response --skip-migration
bin/rails generate model Answer --skip-migration
bin/rails generate model AuditSession --skip-migration
bin/rails generate model ComplianceArea --skip-migration
bin/rails generate model ComplianceAreaScore --skip-migration
```

### Step 2.2: Define Model Associations and Validations

#### `app/models/questionnaire.rb`
```ruby
class Questionnaire < ApplicationRecord
  # Multi-tenancy
  belongs_to :account
  belongs_to :creator, class_name: "User", optional: true

  # Associations
  has_many :sections, -> { order(:order_index) }, dependent: :destroy
  has_many :questions, through: :sections
  has_many :responses, dependent: :destroy
  has_many :logic_rules, through: :questions, source: :logic_rules_as_source

  # Enums
  enum :status, {
    draft: "draft",
    published: "published",
    archived: "archived"
  }, prefix: true

  # Validations
  validates :title, presence: true, length: { maximum: 500 }
  validates :account, presence: true
  validates :status, presence: true

  # Scopes
  scope :active, -> { where(status: :published, deleted_at: nil) }
  scope :for_account, ->(account) { where(account: account) }

  # Soft delete
  def soft_delete
    update(deleted_at: Time.current)
  end

  # Clone for new version
  def duplicate
    new_questionnaire = dup
    new_questionnaire.status = :draft
    new_questionnaire.save!

    sections.each do |section|
      new_section = section.dup
      new_section.questionnaire = new_questionnaire
      new_section.save!

      section.questions.each do |question|
        new_question = question.dup
        new_question.section = new_section
        new_question.save!

        question.answer_choices.each do |choice|
          new_choice = choice.dup
          new_choice.question = new_question
          new_choice.save!
        end
      end
    end

    new_questionnaire
  end
end
```

#### `app/models/section.rb`
```ruby
class Section < ApplicationRecord
  belongs_to :questionnaire
  has_many :questions, -> { order(:order_index) }, dependent: :destroy
  has_many :logic_rules, foreign_key: :target_section_id, dependent: :destroy

  validates :title, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }
  validates :questionnaire, presence: true

  # Check if section should be visible based on logic rules
  def visible_for_response?(response)
    rules = logic_rules.includes(:source_question)
    return true if rules.empty?

    rules.any? do |rule|
      answer = response.answers.find_by(question: rule.source_question)
      answer && rule.evaluate(answer)
    end
  end
end
```

#### `app/models/question.rb`
```ruby
class Question < ApplicationRecord
  belongs_to :section
  has_one :questionnaire, through: :section

  has_many :answer_choices, -> { order(:order_index) }, dependent: :destroy
  has_many :logic_rules_as_source, class_name: "LogicRule",
           foreign_key: :source_question_id, dependent: :destroy
  has_many :answers, dependent: :destroy

  enum :question_type, {
    single_choice: "single_choice",
    multiple_choice: "multiple_choice",
    text_short: "text_short",
    text_long: "text_long",
    yes_no: "yes_no",
    rating_scale: "rating_scale"
  }, prefix: true

  validates :question_text, presence: true
  validates :question_type, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }
  validates :weight, numericality: { greater_than_or_equal_to: 0 }

  # Nested attributes for building questionnaires
  accepts_nested_attributes_for :answer_choices, allow_destroy: true
end
```

#### `app/models/answer_choice.rb`
```ruby
class AnswerChoice < ApplicationRecord
  belongs_to :question

  validates :choice_text, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }
  validates :score, numericality: true, allow_nil: true
end
```

#### `app/models/logic_rule.rb`
```ruby
class LogicRule < ApplicationRecord
  belongs_to :source_question, class_name: "Question"
  belongs_to :target_section, class_name: "Section", optional: true

  enum :condition_type, {
    equals: "equals",
    not_equals: "not_equals",
    contains: "contains",
    greater_than: "greater_than",
    less_than: "less_than"
  }, prefix: true

  enum :action, {
    show: "show",
    hide: "hide",
    skip_to_section: "skip_to_section"
  }, prefix: true

  validates :source_question, presence: true
  validates :condition_type, presence: true
  validates :condition_value, presence: true
  validates :action, presence: true

  # Evaluate if rule condition is met
  def evaluate(answer)
    answer_value = extract_answer_value(answer)
    expected_value = condition_value["value"]

    case condition_type
    when "equals"
      answer_value.to_s == expected_value.to_s
    when "not_equals"
      answer_value.to_s != expected_value.to_s
    when "contains"
      answer_value.to_s.include?(expected_value.to_s)
    when "greater_than"
      answer_value.to_f > expected_value.to_f
    when "less_than"
      answer_value.to_f < expected_value.to_f
    else
      false
    end
  end

  private

  def extract_answer_value(answer)
    case answer.question.question_type
    when "yes_no", "text_short", "text_long"
      answer.answer_value["value"] || answer.answer_value["text"]
    when "single_choice"
      choice = AnswerChoice.find_by(id: answer.answer_value["choice_id"])
      choice&.choice_text
    when "multiple_choice"
      answer.answer_value["choice_ids"]
    when "rating_scale"
      answer.answer_value["rating"]
    else
      answer.answer_value
    end
  end
end
```

#### `app/models/response.rb`
```ruby
class Response < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :account
  belongs_to :respondent, class_name: "User", optional: true

  has_many :answers, dependent: :destroy
  has_one :audit_session, dependent: :destroy

  enum :status, {
    in_progress: "in_progress",
    completed: "completed"
  }, prefix: true

  validates :questionnaire, presence: true
  validates :account, presence: true
  validates :status, presence: true

  # Calculate progress
  def progress_percentage
    return 0 if total_questions.zero?

    (answered_questions.to_f / total_questions * 100).round(2)
  end

  def total_questions
    visible_sections.sum { |s| s.questions.count }
  end

  def answered_questions
    answers.count
  end

  def visible_sections
    questionnaire.sections.select { |section| section.visible_for_response?(self) }
  end

  # Mark as completed
  def complete!
    transaction do
      update!(status: :completed, completed_at: Time.current)
      create_audit_session!
    end
  end

  private

  def create_audit_session!
    AuditSession.create!(
      response: self,
      account: account,
      status: :draft
    )
  end
end
```

#### `app/models/answer.rb`
```ruby
class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question

  validates :response, presence: true
  validates :question, presence: true
  validates :answer_value, presence: true

  # Calculate score based on question type
  before_save :calculate_score

  private

  def calculate_score
    case question.question_type
    when "single_choice"
      choice = AnswerChoice.find_by(id: answer_value["choice_id"])
      self.calculated_score = choice&.score || 0
    when "multiple_choice"
      choice_ids = answer_value["choice_ids"] || []
      scores = AnswerChoice.where(id: choice_ids).pluck(:score).compact
      self.calculated_score = scores.sum
    when "yes_no"
      # You can define scoring logic here
      self.calculated_score = answer_value["value"] == "yes" ? question.weight : 0
    else
      self.calculated_score = 0
    end

    self.calculated_score ||= 0
  end
end
```

#### `app/models/audit_session.rb`
```ruby
class AuditSession < ApplicationRecord
  belongs_to :response
  belongs_to :account
  has_many :compliance_area_scores, dependent: :destroy

  enum :status, {
    draft: "draft",
    completed: "completed"
  }, prefix: true

  validates :response, presence: true
  validates :account, presence: true

  # Calculate compliance scores
  def calculate_scores!
    transaction do
      # Calculate overall score
      total_score = response.answers.sum(:calculated_score)
      max_score = response.questionnaire.questions.sum(:weight)

      update!(
        overall_score: total_score,
        max_possible_score: max_score,
        risk_level: determine_risk_level(total_score, max_score)
      )

      # Calculate compliance area scores
      calculate_compliance_area_scores!

      # Mark as completed
      update!(status: :completed)
    end
  end

  private

  def determine_risk_level(score, max_score)
    return "low" if max_score.zero?

    percentage = (score / max_score.to_f) * 100

    case percentage
    when 80..100 then "low"
    when 50..79 then "medium"
    else "high"
    end
  end

  def calculate_compliance_area_scores!
    # This would be customized based on your GDPR compliance areas
    # For now, we'll create a placeholder
    ComplianceArea.find_each do |area|
      compliance_area_scores.create!(
        compliance_area: area,
        score: 0, # Calculate based on related questions
        max_score: 100
      )
    end
  end
end
```

#### `app/models/compliance_area.rb`
```ruby
class ComplianceArea < ApplicationRecord
  has_many :compliance_area_scores, dependent: :destroy

  validates :name, presence: true
  validates :code, uniqueness: true, allow_nil: true
end
```

#### `app/models/compliance_area_score.rb`
```ruby
class ComplianceAreaScore < ApplicationRecord
  belongs_to :audit_session
  belongs_to :compliance_area

  validates :audit_session, presence: true
  validates :compliance_area, presence: true
  validates :audit_session_id, uniqueness: { scope: :compliance_area_id }

  def percentage
    return 0 if max_score.nil? || max_score.zero?
    (score / max_score.to_f * 100).round(2)
  end
end
```

### Step 2.3: Add Model Concerns

Create `app/models/concerns/account_scoped.rb`:
```ruby
module AccountScoped
  extend ActiveSupport::Concern

  included do
    validates :account, presence: true

    scope :for_account, ->(account) { where(account: account) }
  end
end
```

**Validation:**
```bash
bin/rails console
# Test model associations and validations
Questionnaire.new.valid?
```

---

## Phase 3: Seed Data

### Step 3.1: Create Compliance Areas Seed

Create `db/seeds/compliance_areas.rb`:
```ruby
puts "Seeding GDPR Compliance Areas..."

compliance_areas = [
  {
    name: "Lawfulness, Fairness, Transparency",
    code: "GDPR-PRINCIPLE-1",
    description: "Processing must be lawful, fair and transparent to the data subject"
  },
  {
    name: "Purpose Limitation",
    code: "GDPR-PRINCIPLE-2",
    description: "Data must be collected for specified, explicit and legitimate purposes"
  },
  {
    name: "Data Minimization",
    code: "GDPR-PRINCIPLE-3",
    description: "Data must be adequate, relevant and limited to what is necessary"
  },
  {
    name: "Accuracy",
    code: "GDPR-PRINCIPLE-4",
    description: "Data must be accurate and kept up to date"
  },
  {
    name: "Storage Limitation",
    code: "GDPR-PRINCIPLE-5",
    description: "Data must be kept only as long as necessary"
  },
  {
    name: "Integrity and Confidentiality",
    code: "GDPR-PRINCIPLE-6",
    description: "Data must be processed securely"
  },
  {
    name: "Accountability",
    code: "GDPR-PRINCIPLE-7",
    description: "Controller must demonstrate compliance"
  },
  {
    name: "Records of Processing Activities",
    code: "GDPR-ART-30",
    description: "Maintain records of all processing activities (Monaco: Required for 50+ employees)"
  },
  {
    name: "Security of Processing",
    code: "GDPR-ART-32",
    description: "Implement appropriate technical and organizational measures (Monaco: APDP requirement)"
  },
  {
    name: "Data Protection Impact Assessment",
    code: "GDPR-ART-35",
    description: "Conduct DPIA for high-risk processing (Monaco: APDP requirement)"
  },
  {
    name: "Data Protection Officer",
    code: "GDPR-ART-37",
    description: "Designate a DPO when required (Monaco: APDP requirement in certain cases)"
  }
]

compliance_areas.each do |area_data|
  ComplianceArea.find_or_create_by!(code: area_data[:code]) do |area|
    area.name = area_data[:name]
    area.description = area_data[:description]
  end
end

puts "Created #{ComplianceArea.count} compliance areas"
```

### Step 3.2: Create Sample Questionnaire Seed

Create `db/seeds/sample_questionnaire.rb`:
```ruby
puts "Creating sample GDPR questionnaire..."

# This would be run per account, not globally
# You'd typically do this in a rake task or admin interface

def create_sample_questionnaire(account)
  questionnaire = Questionnaire.create!(
    account: account,
    title: "Monaco RGPD Compliance Assessment",
    description: "Evaluate your organization's compliance with Monaco Law 1.565",
    category: "gdpr",
    status: :published
  )

  # Section 1: Basic Information
  section1 = questionnaire.sections.create!(
    title: "Basic Information",
    description: "Tell us about your organization",
    order_index: 1
  )

  q1 = section1.questions.create!(
    question_text: "Does your organization process personal data?",
    question_type: :yes_no,
    order_index: 1,
    is_required: true,
    weight: 10
  )

  # Section 2: Data Processing (conditional)
  section2 = questionnaire.sections.create!(
    title: "Data Processing Activities",
    description: "Details about your data processing",
    order_index: 2
  )

  # Logic rule: Show section 2 only if q1 == yes
  LogicRule.create!(
    source_question: q1,
    target_section: section2,
    condition_type: :equals,
    condition_value: { value: "yes" },
    action: :show
  )

  section2.questions.create!(
    question_text: "Do you have a Data Protection Officer (DPO)?",
    question_type: :yes_no,
    order_index: 1,
    is_required: true,
    weight: 15
  )

  q3 = section2.questions.create!(
    question_text: "How many individuals' data do you process?",
    question_type: :single_choice,
    order_index: 2,
    is_required: true,
    weight: 10
  )

  q3.answer_choices.create!([
    { choice_text: "Less than 100", order_index: 1, score: 10 },
    { choice_text: "100-1,000", order_index: 2, score: 7 },
    { choice_text: "1,000-10,000", order_index: 3, score: 5 },
    { choice_text: "More than 10,000", order_index: 4, score: 3 }
  ])

  # Section 3: Security Measures
  section3 = questionnaire.sections.create!(
    title: "Security Measures",
    description: "Your data protection measures",
    order_index: 3
  )

  q4 = section3.questions.create!(
    question_text: "What security measures do you have in place?",
    question_type: :multiple_choice,
    order_index: 1,
    is_required: true,
    weight: 20
  )

  q4.answer_choices.create!([
    { choice_text: "Encryption at rest", order_index: 1, score: 5 },
    { choice_text: "Encryption in transit", order_index: 2, score: 5 },
    { choice_text: "Access controls", order_index: 3, score: 4 },
    { choice_text: "Regular backups", order_index: 4, score: 3 },
    { choice_text: "Security audits", order_index: 5, score: 3 }
  ])

  section3.questions.create!(
    question_text: "How would you rate your overall data security?",
    question_type: :rating_scale,
    order_index: 2,
    is_required: true,
    weight: 15,
    settings: { min: 1, max: 10 }
  )

  questionnaire
end

# Example usage (in console or rake task):
# account = Account.first
# create_sample_questionnaire(account)
```

Update `db/seeds.rb`:
```ruby
# Load compliance areas
load Rails.root.join('db', 'seeds', 'compliance_areas.rb')

# Load sample questionnaire (optional, for development)
if Rails.env.development?
  load Rails.root.join('db', 'seeds', 'sample_questionnaire.rb')
end
```

**Validation:**
```bash
bin/rails db:seed
```

---

## Phase 4: Controllers

### Step 4.1: Create Base Controllers

```bash
bin/rails generate controller Questionnaires index show new create edit update destroy
bin/rails generate controller Responses show create update complete
bin/rails generate controller Answers create update
bin/rails generate controller AuditSessions index show
```

### Step 4.2: Implement Controllers

#### `app/controllers/questionnaires_controller.rb`
```ruby
class QuestionnairesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_questionnaire, only: [:show, :edit, :update, :destroy]

  def index
    @questionnaires = current_account.questionnaires
      .where(deleted_at: nil)
      .order(created_at: :desc)

    render inertia: 'Questionnaires/Index',
      props: {
        questionnaires: @questionnaires.map { |q| questionnaire_summary(q) }
      }
  end

  def show
    render inertia: 'Questionnaires/Show',
      props: {
        questionnaire: questionnaire_detail(@questionnaire)
      }
  end

  def new
    render inertia: 'Questionnaires/New'
  end

  def create
    @questionnaire = current_account.questionnaires.build(questionnaire_params)
    @questionnaire.creator = current_user

    if @questionnaire.save
      redirect_to questionnaire_path(@questionnaire),
        notice: 'Questionnaire created successfully'
    else
      redirect_to new_questionnaire_path,
        inertia: { errors: @questionnaire.errors }
    end
  end

  def edit
    render inertia: 'Questionnaires/Edit',
      props: {
        questionnaire: questionnaire_detail(@questionnaire)
      }
  end

  def update
    if @questionnaire.update(questionnaire_params)
      redirect_to questionnaire_path(@questionnaire),
        notice: 'Questionnaire updated successfully'
    else
      redirect_to edit_questionnaire_path(@questionnaire),
        inertia: { errors: @questionnaire.errors }
    end
  end

  def destroy
    @questionnaire.soft_delete
    redirect_to questionnaires_path,
      notice: 'Questionnaire archived successfully'
  end

  private

  def set_questionnaire
    @questionnaire = current_account.questionnaires.find(params[:id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit(
      :title, :description, :category, :status
    )
  end

  def questionnaire_summary(questionnaire)
    {
      id: questionnaire.id,
      title: questionnaire.title,
      description: questionnaire.description,
      category: questionnaire.category,
      status: questionnaire.status,
      created_at: questionnaire.created_at,
      sections_count: questionnaire.sections.count,
      questions_count: questionnaire.questions.count
    }
  end

  def questionnaire_detail(questionnaire)
    {
      id: questionnaire.id,
      title: questionnaire.title,
      description: questionnaire.description,
      category: questionnaire.category,
      status: questionnaire.status,
      sections: questionnaire.sections.includes(questions: :answer_choices).map do |section|
        {
          id: section.id,
          title: section.title,
          description: section.description,
          order_index: section.order_index,
          questions: section.questions.map { |q| question_data(q) }
        }
      end
    }
  end

  def question_data(question)
    {
      id: question.id,
      question_text: question.question_text,
      question_type: question.question_type,
      help_text: question.help_text,
      order_index: question.order_index,
      is_required: question.is_required,
      settings: question.settings,
      weight: question.weight,
      answer_choices: question.answer_choices.map do |choice|
        {
          id: choice.id,
          choice_text: choice.choice_text,
          order_index: choice.order_index,
          score: choice.score
        }
      end
    }
  end
end
```

#### `app/controllers/responses_controller.rb`
```ruby
class ResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_response, only: [:show, :update, :complete]

  def show
    render inertia: 'Questionnaire/Show',
      props: {
        response: response_data(@response),
        questionnaire: questionnaire_data(@response.questionnaire),
        visibleSections: visible_sections_data(@response)
      }
  end

  def create
    questionnaire = current_account.questionnaires.find(params[:questionnaire_id])

    @response = questionnaire.responses.create!(
      account: current_account,
      respondent: current_user,
      status: :in_progress
    )

    redirect_to response_path(@response)
  end

  def update
    # This is for updating answers
    question = Question.find(params[:question_id])

    answer = @response.answers.find_or_initialize_by(question: question)
    answer.answer_value = params[:value]

    if answer.save
      # Return updated visible sections for conditional logic
      render inertia: 'Questionnaire/Show',
        props: {
          visibleSections: visible_sections_data(@response)
        }
    else
      head :unprocessable_entity
    end
  end

  def complete
    @response.complete!

    # Calculate audit scores
    @response.audit_session.calculate_scores!

    redirect_to audit_session_path(@response.audit_session),
      notice: 'Questionnaire submitted successfully'
  end

  private

  def set_response
    @response = current_account.responses.find(params[:id])
  end

  def response_data(response)
    {
      id: response.id,
      status: response.status,
      started_at: response.started_at,
      completed_at: response.completed_at,
      progress_percentage: response.progress_percentage,
      answers: response.answers.map do |answer|
        {
          id: answer.id,
          question_id: answer.question_id,
          answer_value: answer.answer_value,
          calculated_score: answer.calculated_score
        }
      end
    }
  end

  def questionnaire_data(questionnaire)
    {
      id: questionnaire.id,
      title: questionnaire.title,
      description: questionnaire.description,
      category: questionnaire.category
    }
  end

  def visible_sections_data(response)
    response.visible_sections.map do |section|
      {
        id: section.id,
        title: section.title,
        description: section.description,
        order_index: section.order_index,
        questions: section.questions.map do |question|
          {
            id: question.id,
            question_text: question.question_text,
            question_type: question.question_type,
            help_text: question.help_text,
            order_index: question.order_index,
            is_required: question.is_required,
            settings: question.settings,
            answer_choices: question.answer_choices.map do |choice|
              {
                id: choice.id,
                choice_text: choice.choice_text,
                order_index: choice.order_index
              }
            end
          }
        end
      }
    end
  end
end
```

#### `app/controllers/audit_sessions_controller.rb`
```ruby
class AuditSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audit_session, only: [:show]

  def index
    @audit_sessions = current_account.audit_sessions
      .includes(:response)
      .order(created_at: :desc)

    render inertia: 'AuditSessions/Index',
      props: {
        auditSessions: @audit_sessions.map { |audit| audit_summary(audit) }
      }
  end

  def show
    render inertia: 'AuditSessions/Show',
      props: {
        auditSession: audit_detail(@audit_session)
      }
  end

  private

  def set_audit_session
    @audit_session = current_account.audit_sessions.find(params[:id])
  end

  def audit_summary(audit)
    {
      id: audit.id,
      overall_score: audit.overall_score,
      max_possible_score: audit.max_possible_score,
      percentage: audit.max_possible_score&.positive? ?
        (audit.overall_score / audit.max_possible_score * 100).round(2) : 0,
      risk_level: audit.risk_level,
      status: audit.status,
      created_at: audit.created_at
    }
  end

  def audit_detail(audit)
    {
      id: audit.id,
      overall_score: audit.overall_score,
      max_possible_score: audit.max_possible_score,
      risk_level: audit.risk_level,
      status: audit.status,
      created_at: audit.created_at,
      compliance_area_scores: audit.compliance_area_scores.includes(:compliance_area).map do |score|
        {
          id: score.id,
          compliance_area: {
            name: score.compliance_area.name,
            code: score.compliance_area.code,
            description: score.compliance_area.description
          },
          score: score.score,
          max_score: score.max_score,
          percentage: score.percentage
        }
      end,
      response: {
        questionnaire_title: audit.response.questionnaire.title
      }
    }
  end
end
```

**Validation:**
```bash
bin/rails routes | grep questionnaires
bin/rails routes | grep responses
```

---

## Phase 5: Routes Configuration

### Step 5.1: Update Routes

Edit `config/routes.rb`:
```ruby
Rails.application.routes.draw do
  # Existing Jumpstart routes...

  # Questionnaires
  resources :questionnaires do
    member do
      post :duplicate
      patch :publish
      patch :archive
    end

    # Start a new response
    resources :responses, only: [:create]
  end

  # Responses
  resources :responses, only: [:show, :update] do
    member do
      post :complete
    end

    # Answers are nested under responses
    resources :answers, only: [:create, :update]
  end

  # Audit Sessions
  resources :audit_sessions, only: [:index, :show] do
    member do
      get :export_pdf
    end
  end

  # Dashboard
  get 'dashboard', to: 'dashboard#index'
end
```

---

## Phase 6: Svelte Components

### Step 6.1: Create Component Structure

```bash
# Create directories
mkdir -p app/javascript/pages/Questionnaires
mkdir -p app/javascript/pages/Questionnaire
mkdir -p app/javascript/pages/AuditSessions
mkdir -p app/javascript/components/questionnaire
```

### Step 6.2: Create Svelte Components

Files to create:
1. `app/javascript/pages/Questionnaires/Index.svelte` - List of questionnaires
2. `app/javascript/pages/Questionnaires/Show.svelte` - Questionnaire preview
3. `app/javascript/pages/Questionnaire/Show.svelte` - Response form (provided earlier)
4. `app/javascript/pages/Questionnaire/Question.svelte` - Question component (provided earlier)
5. `app/javascript/pages/AuditSessions/Index.svelte` - List of audits
6. `app/javascript/pages/AuditSessions/Show.svelte` - Audit results

#### Example: `app/javascript/pages/Questionnaires/Index.svelte`
```svelte
<script>
	import { router } from '@inertiajs/svelte';

	let { questionnaires } = $props();

	function startQuestionnaire(questionnaireId) {
		router.post(`/questionnaires/${questionnaireId}/responses`);
	}
</script>

<div class="max-w-7xl mx-auto px-4 py-8">
	<div class="flex items-center justify-between mb-8">
		<h1 class="text-3xl font-bold text-gray-900">GDPR Questionnaires</h1>
		<a
			href="/questionnaires/new"
			class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
		>
			New Questionnaire
		</a>
	</div>

	<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
		{#each questionnaires as questionnaire (questionnaire.id)}
			<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
				<div class="mb-4">
					<div class="flex items-center justify-between mb-2">
						<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
							{questionnaire.category}
						</span>
						<span class="text-xs text-gray-500">{questionnaire.status}</span>
					</div>
					<h3 class="text-lg font-semibold text-gray-900 mb-2">
						{questionnaire.title}
					</h3>
					<p class="text-sm text-gray-600 line-clamp-2">
						{questionnaire.description || 'No description'}
					</p>
				</div>

				<div class="flex items-center justify-between text-sm text-gray-500 mb-4">
					<span>{questionnaire.sections_count} sections</span>
					<span>{questionnaire.questions_count} questions</span>
				</div>

				<button
					onclick={() => startQuestionnaire(questionnaire.id)}
					class="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
				>
					Start Assessment
				</button>
			</div>
		{/each}
	</div>
</div>
```

---

## Phase 7: Policies (Authorization)

### Step 7.1: Generate Policies

```bash
bin/rails generate pundit:policy Questionnaire
bin/rails generate pundit:policy Response
bin/rails generate pundit:policy AuditSession
```

### Step 7.2: Implement Policies

#### `app/policies/questionnaire_policy.rb`
```ruby
class QuestionnairePolicy < ApplicationPolicy
  def index?
    true # All authenticated users can see questionnaires for their account
  end

  def show?
    record.account == user.account
  end

  def create?
    user.admin? || user.account_owner?
  end

  def update?
    record.account == user.account && (user.admin? || user.account_owner?)
  end

  def destroy?
    record.account == user.account && (user.admin? || user.account_owner?)
  end

  class Scope < Scope
    def resolve
      scope.where(account: user.account)
    end
  end
end
```

#### `app/policies/response_policy.rb`
```ruby
class ResponsePolicy < ApplicationPolicy
  def show?
    record.account == user.account &&
      (record.respondent == user || user.admin?)
  end

  def update?
    record.account == user.account &&
      record.respondent == user &&
      record.in_progress?
  end

  def complete?
    update?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.where(account: user.account)
      else
        scope.where(account: user.account, respondent: user)
      end
    end
  end
end
```

### Step 7.3: Add Authorization to Controllers

Add to controllers:
```ruby
include Pundit::Authorization

# In each action
authorize @questionnaire  # or @response, @audit_session
```

---

## Phase 8: Testing

### Step 8.1: Model Tests

Create `test/models/questionnaire_test.rb`:
```ruby
require "test_helper"

class QuestionnaireTest < ActiveSupport::TestCase
  test "should belong to account" do
    questionnaire = questionnaires(:basic_gdpr)
    assert_equal accounts(:company), questionnaire.account
  end

  test "should have many sections" do
    questionnaire = questionnaires(:basic_gdpr)
    assert_equal 3, questionnaire.sections.count
  end

  test "should validate presence of title" do
    questionnaire = Questionnaire.new(account: accounts(:company))
    assert_not questionnaire.valid?
    assert_includes questionnaire.errors[:title], "can't be blank"
  end

  test "should duplicate questionnaire with sections and questions" do
    original = questionnaires(:basic_gdpr)
    duplicate = original.duplicate

    assert_equal original.sections.count, duplicate.sections.count
    assert_equal :draft, duplicate.status.to_sym
  end
end
```

Create `test/models/response_test.rb`:
```ruby
require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  test "should calculate progress percentage" do
    response = responses(:in_progress)
    # Assuming 10 total questions and 5 answered
    assert_equal 50.0, response.progress_percentage
  end

  test "should identify visible sections" do
    response = responses(:in_progress)
    visible = response.visible_sections

    assert_includes visible, sections(:basic_info)
    # Add more assertions based on logic rules
  end

  test "should complete and create audit session" do
    response = responses(:in_progress)

    assert_difference 'AuditSession.count', 1 do
      response.complete!
    end

    assert_equal :completed, response.status.to_sym
    assert_not_nil response.completed_at
  end
end
```

### Step 8.2: Controller Tests

Create `test/controllers/responses_controller_test.rb`:
```ruby
require "test_helper"

class ResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @account = @user.account
    sign_in @user
    switch_account(@account)
  end

  test "should show response" do
    response = responses(:in_progress)
    get response_url(response)
    assert_response :success
  end

  test "should update answer" do
    response = responses(:in_progress)
    question = questions(:data_processing)

    patch response_url(response), params: {
      question_id: question.id,
      value: { value: "yes" }
    }

    assert_response :success
    answer = response.answers.find_by(question: question)
    assert_equal "yes", answer.answer_value["value"]
  end

  test "should complete response" do
    response = responses(:in_progress)

    post complete_response_url(response)

    response.reload
    assert_equal :completed, response.status.to_sym
    assert_not_nil response.audit_session
  end
end
```

### Step 8.3: System Tests

Create `test/system/questionnaire_flow_test.rb`:
```ruby
require "application_system_test_case"

class QuestionnaireFlowTest < ApplicationSystemTestCase
  setup do
    @user = users(:regular)
    @account = @user.account
    sign_in @user
    switch_account(@account)
  end

  test "complete questionnaire flow" do
    questionnaire = questionnaires(:basic_gdpr)

    # Start questionnaire
    visit questionnaires_path
    click_on "Start Assessment"

    # Answer questions
    # (This will depend on your actual UI)
    choose "Yes"
    click_on "Next"

    # ... more steps ...

    click_on "Submit"

    # Verify audit session created
    assert_text "Questionnaire submitted successfully"
    assert_current_path audit_session_path(Response.last.audit_session)
  end
end
```

**Validation:**
```bash
bin/rails test
bin/rails test:system
```

---

## Phase 9: Background Jobs (Optional)

### Step 9.1: Create Jobs

```bash
bin/rails generate job CalculateAuditScores
bin/rails generate job GenerateAuditReport
```

#### `app/jobs/calculate_audit_scores_job.rb`
```ruby
class CalculateAuditScoresJob < ApplicationJob
  queue_as :default

  def perform(audit_session_id)
    audit_session = AuditSession.find(audit_session_id)
    audit_session.calculate_scores!
  end
end
```

### Step 9.2: Use Jobs in Controllers

```ruby
# In responses_controller.rb
def complete
  @response.complete!

  # Queue score calculation
  CalculateAuditScoresJob.perform_later(@response.audit_session.id)

  redirect_to audit_session_path(@response.audit_session),
    notice: 'Questionnaire submitted. Calculating scores...'
end
```

---

## Phase 10: Additional Features

### Step 10.1: PDF Export

Add gem to Gemfile:
```ruby
gem 'prawn'
gem 'prawn-table'
```

Create `app/services/audit_pdf_generator.rb`:
```ruby
class AuditPdfGenerator
  def initialize(audit_session)
    @audit_session = audit_session
  end

  def generate
    Prawn::Document.new do |pdf|
      pdf.text "GDPR Compliance Audit Report", size: 24, style: :bold
      pdf.move_down 20

      pdf.text "Overall Score: #{@audit_session.overall_score} / #{@audit_session.max_possible_score}"
      pdf.text "Risk Level: #{@audit_session.risk_level.titleize}"
      pdf.move_down 20

      # Add compliance area scores
      pdf.text "Compliance Area Breakdown", size: 18, style: :bold
      pdf.move_down 10

      @audit_session.compliance_area_scores.each do |score|
        pdf.text "#{score.compliance_area.name}: #{score.percentage}%"
      end
    end.render
  end
end
```

Add to controller:
```ruby
def export_pdf
  pdf = AuditPdfGenerator.new(@audit_session).generate
  send_data pdf, filename: "audit_#{@audit_session.id}.pdf", type: 'application/pdf'
end
```

### Step 10.2: Email Notifications

```bash
bin/rails generate mailer AuditMailer audit_completed
```

#### `app/mailers/audit_mailer.rb`
```ruby
class AuditMailer < ApplicationMailer
  def audit_completed(audit_session_id)
    @audit_session = AuditSession.find(audit_session_id)
    @user = @audit_session.response.respondent

    mail(
      to: @user.email,
      subject: "Your GDPR Audit Results are Ready"
    )
  end
end
```

---

## Phase 11: Deployment Checklist

### Step 11.1: Environment Variables

Add to `.env`:
```
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
```

### Step 11.2: Production Setup

1. Configure database:
```bash
RAILS_ENV=production bin/rails db:create db:migrate
```

2. Precompile assets:
```bash
RAILS_ENV=production bin/rails assets:precompile
```

3. Seed compliance areas:
```bash
RAILS_ENV=production bin/rails db:seed
```

### Step 11.3: Monitoring

Add to Gemfile:
```ruby
gem 'rollbar'  # Error tracking
gem 'scout_apm'  # Performance monitoring
```

---

## Implementation Timeline

### Week 1: Foundation
- Days 1-2: Database migrations and models
- Days 3-4: Seed data and basic validations
- Day 5: Testing models

### Week 2: Core Features
- Days 1-2: Controllers and routes
- Days 3-4: Basic Svelte components
- Day 5: Testing controllers

### Week 3: Advanced Features
- Days 1-2: Conditional logic implementation
- Days 3-4: Scoring and audit calculations
- Day 5: Integration testing

### Week 4: Polish & Deploy
- Days 1-2: UI refinement and UX improvements
- Days 3-4: PDF export, emails, additional features
- Day 5: Deployment and documentation

---

## Success Metrics

- [ ] Users can create questionnaires
- [ ] Users can answer questionnaires
- [ ] Conditional logic works correctly
- [ ] Scores are calculated accurately
- [ ] Audit reports are generated
- [ ] All tests pass
- [ ] Application is deployed
- [ ] Documentation is complete

---

## Next Steps After MVP

1. **Admin Interface**: Build questionnaire builder UI
2. **Analytics Dashboard**: Track completion rates, scores over time
3. **Collaboration**: Multiple users per assessment
4. **Versioning**: Track questionnaire versions
5. **API**: RESTful API for integrations
6. **White-labeling**: Custom branding per account
7. **Advanced Reporting**: More detailed compliance insights
8. **Automation**: Auto-generate recommendations based on answers

---

## Troubleshooting

### Common Issues

**Issue**: Migrations fail
- Check PostgreSQL version compatibility
- Ensure ENUM types don't already exist
- Run migrations individually if needed

**Issue**: Conditional logic not working
- Verify logic_rules are being evaluated
- Check answer_value structure matches expectations
- Add debugging logs in LogicRule#evaluate

**Issue**: Svelte components not updating
- Check Inertia version compatibility
- Ensure props are reactive ($state, $derived)
- Verify controller returns correct data structure

---

## Resources

- **Rails Guides**: https://guides.rubyonrails.org/
- **Svelte 5 Docs**: https://svelte.dev/docs/svelte
- **Inertia.js**: https://inertia-rails.dev/
- **Jumpstart Pro**: Check your account documentation
- **GDPR Reference**: https://gdpr.eu/

---

## Support

For questions or issues during implementation:
1. Check Rails logs: `tail -f log/development.log`
2. Check browser console for Svelte/Inertia errors
3. Review test failures for clues
4. Consult this document's troubleshooting section
