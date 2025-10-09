module Account::GdprQuestionnaires
  extend ActiveSupport::Concern

  included do
    # GDPR Questionnaire System associations
    has_many :questionnaires, class_name: "Gdpr::Questionnaire", dependent: :destroy
    has_many :responses, class_name: "Gdpr::Response", dependent: :destroy
    has_many :audit_sessions, class_name: "Gdpr::AuditSession", dependent: :destroy
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
