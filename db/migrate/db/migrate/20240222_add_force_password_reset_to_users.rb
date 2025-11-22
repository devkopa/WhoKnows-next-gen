class AddForcePasswordResetToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :force_password_reset, :boolean, default: false
  end
end