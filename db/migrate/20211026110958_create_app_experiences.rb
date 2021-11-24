class CreateAppExperiences < ActiveRecord::Migration[6.1]
  def change
    create_table :app_experiences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :app_experiences, [:user_id, :name], unique: true
  end
end
