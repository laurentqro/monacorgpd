class CreateAnswerChoices < ActiveRecord::Migration[8.1]
  def change
    create_table :answer_choices do |t|
      t.references :question, null: false, foreign_key: { on_delete: :cascade }
      t.text :choice_text, null: false
      t.integer :order_index, null: false
      t.decimal :score, precision: 5, scale: 2

      t.timestamps
    end
  end
end
