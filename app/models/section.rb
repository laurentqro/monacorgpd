class Section < ApplicationRecord
  # Associations
  belongs_to :questionnaire
  has_many :questions, dependent: :destroy
  has_many :logic_rules, foreign_key: :target_section_id, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { maximum: 500 }
  validates :order_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(:order_index) }
  scope :for_questionnaire, ->(questionnaire) { where(questionnaire: questionnaire) }

  # Callbacks
  before_validation :set_default_order_index, on: :create

  private

  def set_default_order_index
    return if order_index.present?

    max_order = questionnaire&.sections&.maximum(:order_index) || -1
    self.order_index = max_order + 1
  end
end
