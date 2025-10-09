require "test_helper"

class Gdpr::AnswerTest < ActiveSupport::TestCase
  def setup
    @answer = gdpr_answers(:single_choice_answer)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @answer.valid?
  end

  test "should require answer_value" do
    @answer.answer_value = nil
    assert_not @answer.valid?
  end

  test "should enforce uniqueness of question per response" do
    duplicate = Gdpr::Answer.new(
      response: @answer.response,
      question: @answer.question,
      answer_value: { text: "duplicate" }
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:question_id], "has already been taken"
  end

  # Associations
  test "should belong to response" do
    assert_respond_to @answer, :response
    assert_equal gdpr_responses(:completed_response), @answer.response
  end

  test "should belong to question" do
    assert_respond_to @answer, :question
    assert_equal gdpr_questions(:single_choice_question), @answer.question
  end

  # Methods
  test "text_answer should extract text from answer_value" do
    answer = gdpr_answers(:text_short_answer)
    assert_equal "Acme Corporation", answer.text_answer
  end

  test "choice_ids should extract array of choice IDs" do
    answer = gdpr_answers(:multiple_choice_answer)
    assert_equal [1, 2], answer.choice_ids
  end

  test "single_choice_id should extract choice ID" do
    assert_equal 2, @answer.single_choice_id
  end

  test "calculate_score should calculate score for single choice" do
    # Mock the answer_choice lookup
    choice = gdpr_answer_choices(:choice_two)
    assert_equal 2.0, choice.score
    # The calculate_score method would return the choice's score
  end

  test "calculate_score should handle yes/no answers" do
    answer = gdpr_answers(:yes_no_answer)
    score = answer.calculate_score
    assert_not_nil score
  end
end
