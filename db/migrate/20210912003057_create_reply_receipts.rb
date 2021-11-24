class CreateReplyReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :reply_receipts do |t|
      t.references :reply
      t.references :user
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
