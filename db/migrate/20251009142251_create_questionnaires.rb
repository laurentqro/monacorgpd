class CreateQuestionnaires < ActiveRecord::Migration[8.1]
  def change
    create_table :questionnaires do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, limit: 500
      t.text :description
      t.string :category, limit: 100
      t.references :creator, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :questionnaires, [:account_id, :status],
              where: "deleted_at IS NULL",
              name: 'idx_questionnaires_account_status'
    add_index :questionnaires, [:account_id, :created_at],
              name: 'idx_questionnaires_account_created'
  end
end
