class AddTimestampsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :users, null: true
  end
end
