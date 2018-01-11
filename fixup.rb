require 'tempfile'

DIRS = [
  "tahi_standard_tasks",
  "plos_bio_tech_check",
  "plos_bio_internal_review",
  "plos_billing",
  "tahi/assign_team"
]

DIRS.each do |dir|
  klass_name = dir.camelize
  Dir.glob("**/#{dir}/**/*rb") do |path|
    puts path
    temp_file = Tempfile.new('new_klass')
    begin
      File.open(path, 'r') do |file|
        found_module = false
        file.each_line do |line|
          if line =~ /^module #{klass_name}$/
            # remove the module
            found_module = true
          elsif found_module && line =~ /^end/
            # remove the closing bit
          elsif found_module && line =~ /^  /
            # Remove the indent
            temp_file << line.gsub(/^  /, '')
          else
            temp_file << line
          end
        end
      end
      temp_file.close
      FileUtils.mv(temp_file.path, path)
      new_path = path.gsub(/\/#{dir}/, '')
    ensure
      temp_file.close
      temp_file.unlink
    end
    system "git add #{path}"
    system "mkdir -p #{File.dirname(new_path)}"
    system "git mv -f #{path} #{new_path}"
  end

  Dir.glob('**/*.{rb,js,rake,erb}') do |path|
    next if path =~ /node_modules/
    next if path =~ /bower_components/
    next if path =~ /tmp/
    next if path =~ /db\/migrate/
    replace_dir = "#{dir}/".gsub('/', '\\/')
    ["sed -i 's/#{klass_name}:://g' '#{path}'",
     "sed -i 's/#{replace_dir}//g' '#{path}'"].each do |cmd|
      system cmd
    end
  end
  system "git add ."
  system "git commit -n -m 'APERTA-12034 De-modularized #{klass_name}'"
end
