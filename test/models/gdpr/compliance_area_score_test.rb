require "test_helper"

class Gdpr::ComplianceAreaScoreTest < ActiveSupport::TestCase
  def setup
    @score = gdpr_compliance_area_scores(:lawfulness_score)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @score.valid?
  end

  test "should enforce uniqueness of compliance_area per audit_session" do
    duplicate = Gdpr::ComplianceAreaScore.new(
      audit_session: @score.audit_session,
      compliance_area: @score.compliance_area,
      score: 10.0,
      max_score: 20.0
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:compliance_area_id], "has already been taken"
  end

  test "should allow nil score" do
    @score.score = nil
    assert @score.valid?
  end

  test "should allow nil max_score" do
    @score.max_score = nil
    assert @score.valid?
  end

  # Associations
  test "should belong to audit_session" do
    assert_respond_to @score, :audit_session
    assert_equal gdpr_audit_sessions(:completed_audit), @score.audit_session
  end

  test "should belong to compliance_area" do
    assert_respond_to @score, :compliance_area
    assert_equal gdpr_compliance_areas(:lawfulness), @score.compliance_area
  end

  # Scopes
  test "should scope by audit_session" do
    results = Gdpr::ComplianceAreaScore.for_audit_session(gdpr_audit_sessions(:completed_audit))
    assert_includes results, @score
  end

  test "should scope by compliance_area" do
    results = Gdpr::ComplianceAreaScore.for_compliance_area(gdpr_compliance_areas(:lawfulness))
    assert_includes results, @score
  end

  test "should scope scored records" do
    results = Gdpr::ComplianceAreaScore.scored
    assert results.all? { |s| s.score.present? }
  end

  # Methods
  test "percentage_score should calculate correctly" do
    percentage = @score.percentage_score
    expected = (18.5 / 20.0 * 100).round(2)
    assert_equal expected, percentage
  end

  test "percentage_score should return 0 when max_score is zero" do
    @score.score = 10
    @score.max_score = 0
    assert_equal 0, @score.percentage_score
  end

  test "passing? should return true when percentage >= 70" do
    @score.score = 15.0
    @score.max_score = 20.0
    assert @score.passing?
  end

  test "passing? should return false when percentage < 70" do
    @score.score = 10.0
    @score.max_score = 20.0
    assert_not @score.passing?
  end
end
