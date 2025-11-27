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
      # Aggregate earliest timestamp per username/email from CSV
      entries = {}
      CSV.foreach(path, headers: true) do |row|
        username = (row["username"]||"").to_s.strip
        email = (row["email"]||"").to_s.strip
        ts_raw = (row["ts"]||"").to_s.strip
        next if ts_raw.empty?
        ts = ts_raw[/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/]
        next unless ts
        parsed = Time.parse(ts) rescue next

        key = if username && !username.empty?
          "u:#{username.downcase}"
        elsif email && !email.empty?
          "e:#{email.downcase}"
        else
          nil
        end
        next unless key
        if entries[key].nil? || parsed < entries[key]
          entries[key] = parsed
        end
      end

      updated = 0
      skipped = 0

      entries.each do |key, ts|
        if key.start_with?("u:")
          username = key.sub("u:", "")
          user = User.where("lower(username)=?", username).first
        else
          email = key.sub("e:", "")
          user = User.where("lower(email)=?", email).first
        end

        if user
          if ENV["DRY_RUN"]=="true"
            puts "DRY: would set user #{user.id}/#{user.username} created_at => #{ts}"
          else
            user.update_columns(created_at: ts)
            updated += 1
          end
        else
          skipped += 1
        end
      end

      puts "Done. Updated=#{updated} Skipped=#{skipped}" if ENV["DRY_RUN"]!="true"
    end
  end
end
