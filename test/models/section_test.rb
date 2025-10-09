require "test_helper"

class SectionTest < ActiveSupport::TestCase
  def setup
    @section = sections(:section_one)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @section.valid?
  end

  test "should require title" do
    @section.title = nil
    assert_not @section.valid?
    assert_includes @section.errors[:title], "can't be blank"
  end

  test "should enforce title maximum length" do
    @section.title = "a" * 501
    assert_not @section.valid?
  end

  test "should require order_index" do
    @section.order_index = nil
    assert_not @section.valid?
  end

  test "should require non-negative order_index" do
    @section.order_index = -1
    assert_not @section.valid?
  end

  # Associations
  test "should belong to questionnaire" do
    assert_respond_to @section, :questionnaire
    assert_equal questionnaires(:draft_questionnaire), @section.questionnaire
  end

  test "should have many questions" do
    assert_respond_to @section, :questions
    assert @section.questions.count > 0
  end

  test "should destroy dependent questions" do
    assert_difference "Question.count", -@section.questions.count do
      @section.destroy
    end
  end

  # Scopes
  test "should scope ordered sections" do
    results = Section.ordered
    assert_equal results.first.order_index, results.minimum(:order_index)
  end

  test "should scope by questionnaire" do
    results = Section.for_questionnaire(questionnaires(:draft_questionnaire))
    assert_includes results, @section
    assert_not_includes results, sections(:published_section)
  end

  # Auto order_index
  test "should auto-set order_index on create" do
    new_section = Section.new(
      questionnaire: @section.questionnaire,
      title: "New section"
    )
    new_section.save!
    assert new_section.order_index > @section.order_index
  end
end
