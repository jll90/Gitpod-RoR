class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.references :user
      t.references :product
      t.references :buyer
      t.references :buyer_product
      t.string :state
      t.boolean :user_read, null: false
      t.boolean :buyer_read, null: false
      t.timestamps
    end

    add_index :matches, :state
    add_foreign_key :matches, :users, column: :user_id, primary_key: :id
    add_foreign_key :matches, :users, column: :buyer_id, primary_key: :id
  end
end
