# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :phone, index: true, unique: true
      t.string :email, index: true, unique: true
      t.string :username, index: true, unique: true
      t.string :avatar_url
      t.string :password_digest
      t.string :reset_password_token
      t.datetime :reset_password_sent_at, index: true
      t.string :login_code
      t.datetime :login_code_sent_at
      t.timestamps
    end
  end
end
