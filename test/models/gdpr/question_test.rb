require "test_helper"

class Gdpr::QuestionTest < ActiveSupport::TestCase
  def setup
    @question = gdpr_questions(:single_choice_question)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @question.valid?
  end

  test "should require question_text" do
    @question.question_text = nil
    assert_not @question.valid?
    assert_includes @question.errors[:question_text], "can't be blank"
  end

  test "should require question_type" do
    @question.question_type = nil
    assert_not @question.valid?
  end

  test "should require order_index" do
    @question.order_index = nil
    assert_not @question.valid?
  end

  # Associations
  test "should belong to section" do
    assert_respond_to @question, :section
    assert_equal gdpr_sections(:section_one), @question.section
  end

  test "should have many answer_choices" do
    assert_respond_to @question, :answer_choices
    assert @question.answer_choices.count > 0
  end

  # Enums
  test "should have single_choice type" do
    assert @question.single_choice?
    assert_equal "single_choice", @question.question_type
  end

  test "should have multiple_choice type" do
    question = gdpr_questions(:multiple_choice_question)
    assert question.multiple_choice?
  end

  test "should have text_short type" do
    question = gdpr_questions(:text_short_question)
    assert question.text_short?
  end

  test "should have text_long type" do
    question = gdpr_questions(:text_long_question)
    assert question.text_long?
  end

  test "should have yes_no type" do
    question = gdpr_questions(:yes_no_question)
    assert question.yes_no?
  end

  test "should have rating_scale type" do
    question = gdpr_questions(:rating_scale_question)
    assert question.rating_scale?
  end

  # Scopes
  test "should scope ordered questions" do
    results = Gdpr::Question.ordered
    assert_equal results.first.order_index, results.minimum(:order_index)
  end

  test "should scope required questions" do
    results = Gdpr::Question.required
    assert results.all?(&:is_required)
  end

  test "should scope optional questions" do
    results = Gdpr::Question.optional
    assert results.none?(&:is_required)
  end

  # Methods
  test "single_choice should require choices" do
    assert @question.requires_choices?
  end

  test "text_short should require text" do
    question = gdpr_questions(:text_short_question)
    assert question.requires_text?
  end

  test "rating_scale should require scale settings" do
    question = gdpr_questions(:rating_scale_question)
    assert question.requires_scale_settings?
  end

  # Auto order_index
  test "should auto-set order_index on create" do
    new_question = Gdpr::Question.new(
      section: @question.section,
      question_text: "New question",
      question_type: :text_short
    )
    new_question.save!
    assert new_question.order_index > @question.order_index
  end
end
