# Usage:
# bundle exec rails runner scripts/set_simulated_users_created_at.rb START=2025-11-23 END=2025-11-27

require 'date'
start_date = ENV['START'] ? Date.parse(ENV['START']) : Date.parse('2025-11-23')
end_date = ENV['END'] ? Date.parse(ENV['END']) : Date.parse('2025-11-27')

puts "Setting created_at for users matching 'sim_%' between #{start_date} and #{end_date}"

users = User.where("username LIKE ?", 'sim_%')
puts "Found #{users.count} users"

users.find_each do |u|
  # choose random time on a random day between start_date and end_date
  day = rand((end_date - start_date).to_i + 1)
  date = start_date + day
  # random time during the day
  time = Time.new(date.year, date.month, date.day, rand(0..23), rand(0..59), rand(0..59), "+00:00")
  u.update_columns(created_at: time, updated_at: time)
end

puts "Done."
