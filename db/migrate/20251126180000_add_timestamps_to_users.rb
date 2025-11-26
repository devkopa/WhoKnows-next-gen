class AddTimestampsToUsers < ActiveRecord::Migration[7.0]
  def change
    # add_timestamps adds `created_at` and `updated_at` columns
    # Keep them nullable for now so we can backfill before enforcing NOT NULL
    add_timestamps :users, null: true
  end
end
