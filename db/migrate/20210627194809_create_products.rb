# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.references :user
      t.string :name
      t.string :description
      t.string :price
      t.references :region
      t.st_point :coords, null: false, geographic: true
      t.float :longitude, null: false
      t.float :latitude, null: false
      t.index :coords, using: :gist
      t.index %i[latitude longitude]
      t.string :address
      t.string :state
      t.boolean :archived, null: false, default: false
      t.timestamps
    end

    add_index :products, :state
  end
end
