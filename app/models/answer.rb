class Answer < ApplicationRecord
  # Associations
  belongs_to :response
  belongs_to :question

  # Validations
  validates :answer_value, presence: true
  validates :question_id, uniqueness: { scope: :response_id }
  validates :calculated_score, numericality: true, allow_nil: true

  # Scopes
  scope :for_response, ->(response) { where(response: response) }
  scope :for_question, ->(question) { where(question: question) }
  scope :scored, -> { where.not(calculated_score: nil) }

  # Methods
  def text_answer
    answer_value["text"]
  end

  def choice_ids
    Array(answer_value["choice_ids"])
  end

  def single_choice_id
    answer_value["choice_id"]
  end

  def calculate_score
    case question.question_type.to_sym
    when :single_choice
      choice = question.answer_choices.find_by(id: single_choice_id)
      choice&.score
    when :multiple_choice
      question.answer_choices.where(id: choice_ids).sum(:score)
    when :yes_no
      answer_value["value"] == "yes" ? question.weight : 0
    else
      nil
    end
  end

  def calculate_and_save_score!
    score = calculate_score
    update!(calculated_score: score) if score.present?
  end
end
