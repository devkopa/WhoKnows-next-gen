require 'csv'
require 'zlib'
require 'stringio'

Dir.mkdir('tmp') unless Dir.exist?('tmp')
out = CSV.open('tmp/user_creations.csv','w')
out << ['file','lineno','username','email','ts','line']

# helper to read lines from plain or gz file
def read_lines(path)
  if path.end_with?('.gz')
    begin
      gz = Zlib::GzipReader.open(path)
      lines = gz.read.split("\n")
      gz.close
      return lines
    rescue => e
      puts "Failed to read gz #{path}: #{e}"
      return []
    end
  else
    return File.readlines(path)
  end
end

# consider log files and rotated variants
log_patterns = ['log/*.log', 'log/*.log.*', 'log/*.log.*.gz', 'log/*.gz']
files = log_patterns.flat_map { |p| Dir[p] }.uniq.sort
files.each do |f|
  lines = read_lines(f)
  next if lines.nil? || lines.empty?
  lines.each_with_index do |line,i|
    if line.include?('INSERT INTO "users"') || line =~ /INSERT INTO\s+"users"/i
      # search up to 200 lines above for a timestamp
      ts = nil
      ((i-200)..(i-1)).reverse_each do |k|
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
      email = ''
      if line =~ /VALUES\s*\((.*)\)/i
        vals = $1
        # get all quoted strings inside VALUES
        quoted = vals.scan(/'([^']*)'/).flatten
        # heuristic: first quoted string often username, email contains '@'
        username = quoted[0].to_s if quoted[0]
        email_match = quoted.find { |s| s =~ /@/ }
        email = email_match.to_s if email_match
      end

      out << [f, i+1, username, email, ts, line.strip]
    end
  end
end

out.close
puts "Wrote tmp/user_creations.csv (#{File.size('tmp/user_creations.csv')} bytes)"
