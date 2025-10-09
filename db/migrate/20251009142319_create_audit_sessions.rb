class CreateAuditSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_sessions do |t|
      t.references :response, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :overall_score, precision: 5, scale: 2
      t.decimal :max_possible_score, precision: 5, scale: 2
      t.string :risk_level, limit: 50
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :audit_sessions, [:account_id, :status], name: 'idx_audit_sessions_account_status'
    add_index :audit_sessions, [:account_id, :created_at], name: 'idx_audit_sessions_account_created'
  end
end
