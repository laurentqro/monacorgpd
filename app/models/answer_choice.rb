class AnswerChoice < ApplicationRecord
  # Associations
  belongs_to :question

  # Validations
  validates :choice_text, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :score, numericality: true, allow_nil: true

  # Scopes
  scope :ordered, -> { order(:order_index) }
  scope :for_question, ->(question) { where(question: question) }

  # Callbacks
  before_validation :set_default_order_index, on: :create

  private

  def set_default_order_index
    return if order_index.present?

    max_order = question&.answer_choices&.maximum(:order_index) || -1
    self.order_index = max_order + 1
  end
end
