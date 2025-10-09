require "test_helper"

class Gdpr::AnswerChoiceTest < ActiveSupport::TestCase
  def setup
    @answer_choice = gdpr_answer_choices(:choice_one)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @answer_choice.valid?
  end

  test "should require choice_text" do
    @answer_choice.choice_text = nil
    assert_not @answer_choice.valid?
  end

  test "should require order_index" do
    @answer_choice.order_index = nil
    assert_not @answer_choice.valid?
  end

  test "should require non-negative order_index" do
    @answer_choice.order_index = -1
    assert_not @answer_choice.valid?
  end

  test "should allow nil score" do
    @answer_choice.score = nil
    assert @answer_choice.valid?
  end

  # Associations
  test "should belong to question" do
    assert_respond_to @answer_choice, :question
    assert_equal gdpr_questions(:single_choice_question), @answer_choice.question
  end

  # Scopes
  test "should scope ordered answer_choices" do
    results = Gdpr::AnswerChoice.ordered
    assert_equal results.first.order_index, results.minimum(:order_index)
  end

  test "should scope by question" do
    results = Gdpr::AnswerChoice.for_question(gdpr_questions(:single_choice_question))
    assert_includes results, @answer_choice
    assert_not_includes results, gdpr_answer_choices(:multiple_choice_one)
  end

  # Auto order_index
  test "should auto-set order_index on create" do
    new_choice = Gdpr::AnswerChoice.new(
      question: @answer_choice.question,
      choice_text: "New choice"
    )
    new_choice.save!
    assert new_choice.order_index > @answer_choice.order_index
  end
end
