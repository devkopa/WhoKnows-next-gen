namespace :users do
  desc "Backfill users.created_at from tmp/user_creations.csv (DRY_RUN=true to preview)"
  task backfill_timestamps: :environment do
    require "csv"
    path = Rails.root.join("tmp", "user_creations.csv")
    abort "CSV missing: #{path}" unless File.exist?(path)
    updated = 0
    skipped = 0
    CSV.foreach(path, headers: true).with_index(1) do |row, idx|
      username = (row["username"]||"").to_s.strip
      ts_raw = (row["ts"]||"").to_s.strip
      next if ts_raw.empty?
      ts = ts_raw[/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/]
      next unless ts
      parsed = Time.parse(ts) rescue next

      user = nil
      if username && !username.empty?
        user = User.where("lower(username)=?", username.downcase).first
      end

      if user.nil? && row["line"]
        sql = row["line"]
        if sql =~ /VALUES\s*\((.*)\)/i
          vals = $1
          parts = vals.scan(/'([^']*)'|([^,\s]+)/).map { |a, b|(a||b) }.map(&:to_s)
          maybe_username = parts[0].to_s.strip
          maybe_email = parts.find { |p| p =~ /@/ }
          user = User.where("lower(username)=?", maybe_username.downcase).first if maybe_username.present?
          user ||= User.where("lower(email)=?", maybe_email.downcase).first if maybe_email
        end
      end

      if user
        if ENV["DRY_RUN"]=="true"
          puts "DRY: would set user #{user.id}/#{user.username} created_at => #{parsed} (row #{idx})"
        else
          user.update_columns(created_at: parsed)
          updated += 1
        end
      else
        skipped += 1
      end
    end
    puts "Done. Updated=#{updated} Skipped=#{skipped}" if ENV["DRY_RUN"]!="true"
  end
end
