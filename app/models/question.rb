class Question < ApplicationRecord
  # Enums
  enum :question_type, {
    single_choice: 0,
    multiple_choice: 1,
    text_short: 2,
    text_long: 3,
    yes_no: 4,
    rating_scale: 5
  }

  # Associations
  belongs_to :section
  has_one :questionnaire, through: :section
  has_many :answer_choices, dependent: :destroy
  has_many :logic_rules, foreign_key: :source_question_id, dependent: :destroy
  has_many :answers, dependent: :destroy

  # Validations
  validates :question_text, presence: true
  validates :question_type, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :ordered, -> { order(:order_index) }
  scope :required, -> { where(is_required: true) }
  scope :optional, -> { where(is_required: false) }
  scope :for_section, ->(section) { where(section: section) }

  # Callbacks
  before_validation :set_default_order_index, on: :create

  # Methods
  def requires_choices?
    single_choice? || multiple_choice? || yes_no?
  end

  def requires_text?
    text_short? || text_long?
  end

  def requires_scale_settings?
    rating_scale?
  end

  private

  def set_default_order_index
    return if order_index.present?

    max_order = section&.questions&.maximum(:order_index) || -1
    self.order_index = max_order + 1
  end
end
