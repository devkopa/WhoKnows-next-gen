count = User.count
puts "Found #{count} users"
count.times { USER_REGISTRATIONS.increment }
puts "user_registrations_total initialized to #{count}"
