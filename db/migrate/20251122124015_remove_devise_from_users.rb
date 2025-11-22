class RemoveDeviseFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :encrypted_password, :string if column_exists?(:users, :encrypted_password)
    remove_column :users, :reset_password_token, :string if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at, :datetime if column_exists?(:users, :remember_created_at)
    remove_column :users, :force_password_reset, :boolean if column_exists?(:users, :force_password_reset)

    add_column :users, :password_digest, :string unless column_exists?(:users, :password_digest)
  end
end