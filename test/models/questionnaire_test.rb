require "test_helper"

class QuestionnaireTest < ActiveSupport::TestCase
  def setup
    @questionnaire = questionnaires(:draft_questionnaire)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @questionnaire.valid?
  end

  test "should require title" do
    @questionnaire.title = nil
    assert_not @questionnaire.valid?
    assert_includes @questionnaire.errors[:title], "can't be blank"
  end

  test "should enforce title maximum length" do
    @questionnaire.title = "a" * 501
    assert_not @questionnaire.valid?
    assert_includes @questionnaire.errors[:title], "is too long (maximum is 500 characters)"
  end

  test "should enforce category maximum length" do
    @questionnaire.category = "a" * 101
    assert_not @questionnaire.valid?
    assert_includes @questionnaire.errors[:category], "is too long (maximum is 100 characters)"
  end

  # Associations
  test "should belong to account" do
    assert_respond_to @questionnaire, :account
    assert_equal accounts(:one), @questionnaire.account
  end

  test "should belong to creator" do
    assert_respond_to @questionnaire, :creator
    assert_equal users(:one), @questionnaire.creator
  end

  test "should have many sections" do
    assert_respond_to @questionnaire, :sections
    assert_includes @questionnaire.sections, sections(:section_one)
  end

  test "should have many responses" do
    assert_respond_to @questionnaire, :responses
  end

  test "should destroy dependent sections" do
    assert_difference "Section.count", -@questionnaire.sections.count do
      @questionnaire.destroy
    end
  end

  # Enums
  test "should have draft status enum" do
    @questionnaire.draft!
    assert @questionnaire.draft?
    assert_equal "draft", @questionnaire.status
  end

  test "should have published status enum" do
    @questionnaire.published!
    assert @questionnaire.published?
    assert_equal "published", @questionnaire.status
  end

  test "should have archived status enum" do
    @questionnaire.archived!
    assert @questionnaire.archived?
    assert_equal "archived", @questionnaire.status
  end

  # Scopes
  test "should scope by account" do
    results = Questionnaire.for_account(accounts(:one))
    assert_includes results, @questionnaire
    assert_not_includes results, questionnaires(:account_two_questionnaire)
  end

  test "should scope active questionnaires" do
    results = Questionnaire.active
    assert_includes results, @questionnaire
    assert_not_includes results, questionnaires(:deleted_questionnaire)
  end

  test "should scope by status" do
    results = Questionnaire.by_status(:draft)
    assert_includes results, @questionnaire
    assert_not_includes results, questionnaires(:published_questionnaire)
  end

  # Soft delete
  test "should soft delete questionnaire" do
    @questionnaire.soft_delete
    assert @questionnaire.deleted?
    assert_not_nil @questionnaire.deleted_at
  end

  test "should restore soft deleted questionnaire" do
    @questionnaire.soft_delete
    @questionnaire.restore
    assert_not @questionnaire.deleted?
    assert_nil @questionnaire.deleted_at
  end
end
