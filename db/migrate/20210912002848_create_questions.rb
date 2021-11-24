class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.references :product
      t.references :user
      t.references :addressee
      t.text  :content
      t.string :state
      t.timestamps
    end

    add_foreign_key :questions, :users, column: :user_id, primary_key: :id
    add_foreign_key :questions, :users, column: :addressee_id, primary_key: :id
  end
end
