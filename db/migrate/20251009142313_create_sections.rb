class CreateSections < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.references :questionnaire, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, limit: 500
      t.text :description
      t.integer :order_index, null: false

      t.timestamps
    end

    add_index :sections, [:questionnaire_id, :order_index], name: 'idx_sections_order'
  end
end
