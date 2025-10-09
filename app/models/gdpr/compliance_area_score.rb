module Gdpr
    class ComplianceAreaScore < ApplicationRecord
    # Associations
    belongs_to :audit_session
    belongs_to :compliance_area
  
    # Validations
    validates :compliance_area_id, uniqueness: { scope: :audit_session_id }
    validates :score, numericality: true, allow_nil: true
    validates :max_score, numericality: true, allow_nil: true
  
    # Scopes
    scope :for_audit_session, ->(audit_session) { where(audit_session: audit_session) }
    scope :for_compliance_area, ->(compliance_area) { where(compliance_area: compliance_area) }
    scope :scored, -> { where.not(score: nil) }
  
    # Methods
    def percentage_score
      return 0 if max_score.nil? || max_score.zero?
      (score.to_f / max_score * 100).round(2)
    end
  
    def passing?
      percentage_score >= 70
    end
  end
end
