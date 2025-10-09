class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :section, null: false, foreign_key: { on_delete: :cascade }
      t.text :question_text, null: false
      t.integer :question_type, null: false
      t.text :help_text
      t.integer :order_index, null: false
      t.boolean :is_required, null: false, default: false
      t.jsonb :settings, default: {}
      t.decimal :weight, precision: 5, scale: 2, default: 1.0

      t.timestamps
    end

    add_index :questions, [:section_id, :order_index], name: 'idx_questions_order'
    add_index :questions, :settings, using: :gin, name: 'idx_questions_settings_gin'
  end
end
