class CreateComplianceAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :compliance_areas do |t|
      t.string :name, null: false, limit: 255
      t.string :code, limit: 100
      t.text :description

      t.timestamps
    end

    add_index :compliance_areas, :code, unique: true, name: 'idx_compliance_areas_code'
  end
end
