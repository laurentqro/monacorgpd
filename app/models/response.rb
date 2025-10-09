class Response < ApplicationRecord
  # Enums
  enum :status, { in_progress: 0, completed: 1 }, default: :in_progress

  # Associations
  belongs_to :questionnaire
  belongs_to :account
  belongs_to :respondent, class_name: "User", optional: true
  has_many :answers, dependent: :destroy
  has_one :audit_session, dependent: :destroy

  # Validations
  validates :status, presence: true
  validates :started_at, presence: true

  # Scopes
  scope :for_account, ->(account) { where(account: account) }
  scope :for_questionnaire, ->(questionnaire) { where(questionnaire: questionnaire) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def complete!
    update!(status: :completed, completed_at: Time.current)
  end

  def duration
    return nil unless completed_at && started_at
    completed_at - started_at
  end

  def completion_percentage
    total_questions = questionnaire.questions.count
    return 0 if total_questions.zero?

    answered_questions = answers.count
    (answered_questions.to_f / total_questions * 100).round(2)
  end
end
