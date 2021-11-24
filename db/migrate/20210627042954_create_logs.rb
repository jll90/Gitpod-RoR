class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.references :loggable
      t.string :loggable_type
      t.string :event
      t.json :info
      t.timestamps
    end
  end
end
