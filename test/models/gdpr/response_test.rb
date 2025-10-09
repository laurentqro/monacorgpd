require "test_helper"

class Gdpr::ResponseTest < ActiveSupport::TestCase
  def setup
    @response = gdpr_responses(:in_progress_response)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @response.valid?
  end

  test "should require status" do
    @response.status = nil
    assert_not @response.valid?
  end

  # Associations
  test "should belong to questionnaire" do
    assert_respond_to @response, :questionnaire
    assert_equal gdpr_questionnaires(:draft_questionnaire), @response.questionnaire
  end

  test "should belong to account" do
    assert_respond_to @response, :account
    assert_equal accounts(:one), @response.account
  end

  test "should have many answers" do
    assert_respond_to @response, :answers
  end

  # Enums
  test "should have in_progress status" do
    assert @response.in_progress?
    assert_equal "in_progress", @response.status
  end

  test "should have completed status" do
    response = gdpr_responses(:completed_response)
    assert response.completed?
    assert_equal "completed", response.status
  end

  # Scopes
  test "should scope by account" do
    results = Gdpr::Response.for_account(accounts(:one))
    assert_includes results, @response
    assert_not_includes results, gdpr_responses(:account_two_response)
  end

  test "should scope by status" do
    results = Gdpr::Response.by_status(:in_progress)
    assert_includes results, @response
    assert_not_includes results, gdpr_responses(:completed_response)
  end

  # Methods
  test "complete! should set status and completed_at" do
    @response.complete!
    assert @response.completed?
    assert_not_nil @response.completed_at
  end

  test "duration should calculate time difference" do
    response = gdpr_responses(:completed_response)
    assert_not_nil response.duration
    assert response.duration > 0
  end

  test "duration should return nil when not completed" do
    assert_nil @response.duration
  end

  test "completion_percentage should calculate correctly" do
    response = gdpr_responses(:completed_response)
    percentage = response.completion_percentage
    assert percentage >= 0
    assert percentage <= 100
  end
end
