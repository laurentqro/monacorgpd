require "test_helper"

class Gdpr::AuditSessionTest < ActiveSupport::TestCase
  def setup
    @audit_session = gdpr_audit_sessions(:draft_audit)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @audit_session.valid?
  end

  test "should require status" do
    @audit_session.status = nil
    assert_not @audit_session.valid?
  end

  # Associations
  test "should belong to response" do
    assert_respond_to @audit_session, :response
    assert_equal gdpr_responses(:completed_response), @audit_session.response
  end

  test "should belong to account" do
    assert_respond_to @audit_session, :account
    assert_equal accounts(:one), @audit_session.account
  end

  test "should have many compliance_area_scores" do
    assert_respond_to @audit_session, :compliance_area_scores
  end

  # Enums
  test "should have draft status" do
    assert @audit_session.draft?
    assert_equal "draft", @audit_session.status
  end

  test "should have completed status" do
    audit = gdpr_audit_sessions(:completed_audit)
    assert audit.completed?
  end

  # Scopes
  test "should scope by account" do
    results = Gdpr::AuditSession.for_account(accounts(:one))
    assert_includes results, @audit_session
  end

  test "should scope by status" do
    results = Gdpr::AuditSession.by_status(:draft)
    assert_includes results, @audit_session
  end

  # Methods
  test "percentage_score should calculate correctly" do
    audit = gdpr_audit_sessions(:completed_audit)
    percentage = audit.percentage_score
    assert_equal 75.5, percentage
  end

  test "percentage_score should return 0 when max_score is zero" do
    @audit_session.overall_score = 10
    @audit_session.max_possible_score = 0
    assert_equal 0, @audit_session.percentage_score
  end

  test "complete! should set status to completed" do
    # Need to mock calculate_overall_score or set up proper test data
    @audit_session.overall_score = 50
    @audit_session.max_possible_score = 100
    @audit_session.risk_level = "medium"
    @audit_session.complete!
    assert @audit_session.completed?
  end
end
