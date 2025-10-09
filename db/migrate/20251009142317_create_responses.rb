class CreateResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :responses do |t|
      t.references :questionnaire, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.references :respondent, foreign_key: { to_table: :users, on_delete: :nullify }
      t.integer :status, null: false, default: 0
      t.datetime :started_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :completed_at

      t.timestamps
    end

    add_index :responses, [:account_id, :status], name: 'idx_responses_account_status'
    add_index :responses, [:account_id, :created_at], name: 'idx_responses_account_created'
  end
end
