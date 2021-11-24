class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user
      t.references :log
      t.string :title
      t.text :content
      t.boolean :read, default: false
      t.timestamps
    end

    add_index :notifications, :read
  end
end
