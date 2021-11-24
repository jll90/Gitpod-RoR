class CreateReplies < ActiveRecord::Migration[6.1]
  def change
    create_table :replies do |t|
      t.references :question
      t.references :user
      t.text :content
      t.string :state
      t.timestamps
    end
  end
end
