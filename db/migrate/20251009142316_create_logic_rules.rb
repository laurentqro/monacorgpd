class CreateLogicRules < ActiveRecord::Migration[8.1]
  def change
    create_table :logic_rules do |t|
      t.references :source_question, null: false, foreign_key: { to_table: :questions, on_delete: :cascade }
      t.references :target_section, foreign_key: { to_table: :sections, on_delete: :cascade }
      t.integer :condition_type, null: false
      t.jsonb :condition_value, null: false
      t.integer :action, null: false

      t.timestamps
    end

    add_index :logic_rules, :source_question_id, name: 'idx_logic_rules_source'
    add_index :logic_rules, :target_section_id, name: 'idx_logic_rules_target_section'
  end
end
