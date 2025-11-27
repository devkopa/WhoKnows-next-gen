class CreateWeatherSearches < ActiveRecord::Migration[8.0]
  def change
    create_table :weather_searches do |t|
      t.string :city
      t.string :user_ip

      t.timestamps
    end
  end
end
