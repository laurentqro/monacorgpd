class AddNotesToResponses < ActiveRecord::Migration[8.1]
  def change
    add_column :responses, :notes, :text
  end
end
