class CreateDevicesTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :devices_tokens do |t|
      t.references :user
      t.string :operating_system
      t.string :token
      t.string :device_uniq_id
      t.timestamps
    end
    
    add_index :devices_tokens, [:user_id, :device_uniq_id]
  end
end
