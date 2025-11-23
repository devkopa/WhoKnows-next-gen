class CreateSearchLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :search_logs do |t|
      t.string :query
      t.string :user_ip

      t.timestamps
    end
  end
end
