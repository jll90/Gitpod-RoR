class CreateSwipes < ActiveRecord::Migration[6.1]
  def change
    create_table :swipes do |t|
      t.references :user
      t.references :product
      t.boolean :liked
      t.timestamps
    end
  end
end
