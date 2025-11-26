require 'csv'
Dir.mkdir('tmp') unless Dir.exist?('tmp')
out = CSV.open('tmp/user_creations.csv', 'w')
out << [ 'file', 'lineno', 'username', 'ts', 'line' ]
Dir['log/*.log'].each do |f|
  lines = File.readlines(f)
  lines.each_with_index do |line, i|
    if line.include?('INSERT INTO "users"')
      # find timestamp up to 20 lines above
      ts = nil
      ((i-20)..(i-1)).reverse_each do |k|
        next if k < 0
        l = lines[k]
        if l =~ /at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/
          ts = $1
          break
        elsif l =~ /(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/
          ts = $1; break
        end
      end
      username = ''
      if line =~ /VALUES\s*\((.*)\)/i
        vals = $1
        if vals =~ /'([^']+)'/
          username = $1
        end
      end
      out << [ f, i+1, username, ts, line.strip ]
    end
  end
end
out.close
