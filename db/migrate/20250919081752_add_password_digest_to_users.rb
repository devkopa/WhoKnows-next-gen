class AddPasswordDigestToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string
    end
  end
end