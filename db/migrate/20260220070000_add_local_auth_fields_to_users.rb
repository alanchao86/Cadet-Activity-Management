# frozen_string_literal: true

class AddLocalAuthFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_column :users, :password_digest, :string
    add_index :users, 'LOWER(username)', unique: true, name: 'index_users_on_lower_username', where: 'username IS NOT NULL'
  end
end
