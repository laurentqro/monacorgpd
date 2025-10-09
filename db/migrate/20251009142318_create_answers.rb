class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :response, null: false, foreign_key: { on_delete: :cascade }
      t.references :question, null: false, foreign_key: { on_delete: :cascade }
      t.jsonb :answer_value, null: false
      t.decimal :calculated_score, precision: 5, scale: 2

      t.timestamps
    end

    add_index :answers, [:response_id, :question_id], unique: true, name: 'idx_answers_response_question'
    add_index :answers, :answer_value, using: :gin, name: 'idx_answers_value_gin'
  end
end
