module Account::GdprQuestionnaires
  extend ActiveSupport::Concern

  included do
    # GDPR Questionnaire System associations
    has_many :questionnaires, dependent: :destroy
    has_many :responses, dependent: :destroy
    has_many :audit_sessions, dependent: :destroy
  end

  # Helper methods for GDPR functionality
  def active_questionnaires
    questionnaires.active.published
  end

  def draft_questionnaires
    questionnaires.active.draft
  end

  def completed_responses
    responses.completed
  end

  def in_progress_responses
    responses.in_progress
  end

  def latest_audit_sessions(limit = 5)
    audit_sessions.completed.order(created_at: :desc).limit(limit)
  end
end
