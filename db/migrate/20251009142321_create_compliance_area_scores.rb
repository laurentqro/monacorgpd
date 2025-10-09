class CreateComplianceAreaScores < ActiveRecord::Migration[8.1]
  def change
    create_table :compliance_area_scores do |t|
      t.references :audit_session, null: false, foreign_key: { on_delete: :cascade }
      t.references :compliance_area, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :score, precision: 5, scale: 2
      t.decimal :max_score, precision: 5, scale: 2

      t.timestamps
    end

    add_index :compliance_area_scores, [:audit_session_id, :compliance_area_id],
              unique: true,
              name: 'idx_compliance_area_scores_unique'
  end
end
