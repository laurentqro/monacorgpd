class LogicRule < ApplicationRecord
  # Enums
  enum :condition_type, {
    equals: 0,
    not_equals: 1,
    contains: 2,
    greater_than: 3,
    less_than: 4
  }

  enum :action, {
    show: 0,
    hide: 1,
    skip_to_section: 2
  }

  # Associations
  belongs_to :source_question, class_name: "Question"
  belongs_to :target_section, class_name: "Section", optional: true

  # Validations
  validates :condition_type, presence: true
  validates :condition_value, presence: true
  validates :action, presence: true

  # Scopes
  scope :for_question, ->(question) { where(source_question: question) }
  scope :for_section, ->(section) { where(target_section: section) }

  # Methods
  def evaluate(answer_value)
    case condition_type.to_sym
    when :equals
      answer_value == condition_value
    when :not_equals
      answer_value != condition_value
    when :contains
      Array(answer_value).include?(condition_value)
    when :greater_than
      answer_value.to_f > condition_value.to_f
    when :less_than
      answer_value.to_f < condition_value.to_f
    else
      false
    end
  end
end
