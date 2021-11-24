class CreateUpdateRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :update_requests do |t|
      t.references :user, foreign_key: true
      t.string :old_value, null: false
      t.string :new_value
      t.string :type, null: false
      t.string :token, null: false
      t.string :code, null: false
      t.timestamp :expires_at, null: false
      t.timestamp :effected_at

      t.timestamps
    end

    ## on the fence about these indeces
    add_index :update_requests, [:user_id, :expires_at]
    add_index :update_requests, [:user_id, :effected_at]
  end
end

