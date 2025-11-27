class AddLastLoginToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_login, :datetime
    add_index :users, :last_login
  end
end
