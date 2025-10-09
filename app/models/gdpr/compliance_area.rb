module Gdpr
    class ComplianceArea < ApplicationRecord
    # Associations
    has_many :compliance_area_scores, dependent: :destroy
    has_many :audit_sessions, through: :compliance_area_scores
  
    # Validations
    validates :name, presence: true, length: { maximum: 255 }
    validates :code, uniqueness: true, allow_blank: true, length: { maximum: 100 }
  
    # Scopes
    scope :by_code, -> { order(:code) }
    scope :by_name, -> { order(:name) }
    scope :with_code, -> { where.not(code: nil) }
  end
end
