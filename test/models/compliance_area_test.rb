require "test_helper"

class ComplianceAreaTest < ActiveSupport::TestCase
  def setup
    @compliance_area = compliance_areas(:lawfulness)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @compliance_area.valid?
  end

  test "should require name" do
    @compliance_area.name = nil
    assert_not @compliance_area.valid?
    assert_includes @compliance_area.errors[:name], "can't be blank"
  end

  test "should enforce name maximum length" do
    @compliance_area.name = "a" * 256
    assert_not @compliance_area.valid?
  end

  test "should enforce unique code" do
    duplicate = ComplianceArea.new(
      name: "Duplicate",
      code: @compliance_area.code
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:code], "has already been taken"
  end

  test "should allow nil code" do
    @compliance_area.code = nil
    assert @compliance_area.valid?
  end

  # Associations
  test "should have many compliance_area_scores" do
    assert_respond_to @compliance_area, :compliance_area_scores
  end

  test "should have many audit_sessions through compliance_area_scores" do
    assert_respond_to @compliance_area, :audit_sessions
  end

  # Scopes
  test "should scope by code" do
    results = ComplianceArea.by_code
    assert_equal results.first.code, results.minimum(:code)
  end

  test "should scope by name" do
    results = ComplianceArea.by_name
    codes = results.map(&:name)
    assert_equal codes, codes.sort
  end

  test "should scope with_code" do
    results = ComplianceArea.with_code
    assert results.all? { |ca| ca.code.present? }
  end
end
