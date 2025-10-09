module Gdpr
    class AuditSession < ApplicationRecord
    # Enums
    enum :status, { draft: 0, completed: 1 }, default: :draft
  
    # Associations
    belongs_to :response
    belongs_to :account
    has_many :compliance_area_scores, dependent: :destroy
    has_many :compliance_areas, through: :compliance_area_scores
  
    # Validations
    validates :status, presence: true
  
    # Scopes
    scope :for_account, ->(account) { where(account: account) }
    scope :by_status, ->(status) { where(status: status) }
    scope :recent, -> { order(created_at: :desc) }
  
    # Methods
    def calculate_overall_score
      total_score = response.answers.sum(:calculated_score) || 0
      max_score = response.questionnaire.questions.sum(:weight) || 0
  
      update!(
        overall_score: total_score,
        max_possible_score: max_score,
        risk_level: determine_risk_level(total_score, max_score)
      )
    end
  
    def percentage_score
      return 0 if max_possible_score.nil? || max_possible_score.zero?
      (overall_score.to_f / max_possible_score * 100).round(2)
    end
  
    def complete!
      calculate_overall_score
      update!(status: :completed)
    end
  
    private
  
    def determine_risk_level(score, max_score)
      return "unknown" if max_score.zero?
  
      percentage = (score.to_f / max_score * 100)
  
      if percentage >= 80
        "low"
      elsif percentage >= 50
        "medium"
      else
        "high"
      end
    end
  end
end
