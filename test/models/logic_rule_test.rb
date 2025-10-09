require "test_helper"

class LogicRuleTest < ActiveSupport::TestCase
  def setup
    @logic_rule = logic_rules(:show_section_rule)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @logic_rule.valid?
  end

  test "should require condition_type" do
    @logic_rule.condition_type = nil
    assert_not @logic_rule.valid?
  end

  test "should require condition_value" do
    @logic_rule.condition_value = nil
    assert_not @logic_rule.valid?
  end

  test "should require action" do
    @logic_rule.action = nil
    assert_not @logic_rule.valid?
  end

  # Associations
  test "should belong to source_question" do
    assert_respond_to @logic_rule, :source_question
    assert_equal questions(:single_choice_question), @logic_rule.source_question
  end

  test "should optionally belong to target_section" do
    assert_respond_to @logic_rule, :target_section
    assert_equal sections(:section_two), @logic_rule.target_section
  end

  # Enums
  test "should have equals condition_type" do
    assert @logic_rule.equals?
  end

  test "should have show action" do
    assert @logic_rule.show?
  end

  test "should have hide action" do
    rule = logic_rules(:hide_section_rule)
    assert rule.hide?
  end

  test "should have skip_to_section action" do
    rule = logic_rules(:skip_to_section_rule)
    assert rule.skip_to_section?
  end

  # Scopes
  test "should scope by question" do
    results = LogicRule.for_question(questions(:single_choice_question))
    assert_includes results, @logic_rule
  end

  test "should scope by section" do
    results = LogicRule.for_section(sections(:section_two))
    assert_includes results, @logic_rule
  end

  # Methods
  test "evaluate should return true for equals match" do
    @logic_rule.condition_value = { "value" => 3 }
    assert @logic_rule.evaluate({ "value" => 3 })
  end

  test "evaluate should return false for equals non-match" do
    @logic_rule.condition_value = { "value" => 3 }
    assert_not @logic_rule.evaluate({ "value" => 2 })
  end

  test "evaluate should handle not_equals" do
    @logic_rule.not_equals!
    @logic_rule.condition_value = { "value" => 3 }
    assert @logic_rule.evaluate({ "value" => 2 })
  end

  test "evaluate should handle contains" do
    @logic_rule.contains!
    @logic_rule.condition_value = 2
    assert @logic_rule.evaluate([1, 2, 3])
  end

  test "evaluate should handle greater_than" do
    @logic_rule.greater_than!
    @logic_rule.condition_value = 5
    assert @logic_rule.evaluate(10)
  end

  test "evaluate should handle less_than" do
    @logic_rule.less_than!
    @logic_rule.condition_value = 10
    assert @logic_rule.evaluate(5)
  end
end
