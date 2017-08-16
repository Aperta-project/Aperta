namespace :data do
  namespace :populate_initial_roles do
    require 'open-uri'
    require 'csv'
    desc <<-DESC.strip_heredoc
      This populates the initial roles based upon a CSV file.

      Examples:
        rake  data:populate_initial_roles[path/to/local/file.csv]
        rake  data:populate_initial_roles[http://example.com/some.csv]

      The CSV file should have the format:
        Name,Email,Role,Journals
        Jane Doe,jane@example.edu,Site Admin,Biology and Things
        John Doe,john@example.edu,Staff Admin,Biology and Things
        John Roe,roe@example.edu,User,Biology and Things
        ...
      DESC
    task :csv, [:csv_url] => [:environment] do |_, args|
      if args[:csv_url].present?
        CSV.parse(open(args[:csv_url]), row_sep: :auto, headers: :first_row) do |csv|
          if csv["Email"].present?
            STDERR.puts("user #{csv['Email']}")
            csv["Email"] = csv["Email"].strip.downcase
            user = User.find_or_create_by(email: csv['Email']) do |new_user|
              new_user.username = csv["Email"].split('@').first.delete('.')
              new_user.first_name = csv["Name"].split.first if csv["Name"].try(:split).try(:count) == 2
              new_user.last_name = csv["Name"].split.last if csv["Name"].try(:split).try(:count) == 2
              new_user.auto_generate_password
              STDERR.puts('  creating...')
              STDERR.puts("  with username: #{new_user.username}")
              STDERR.puts("       name: #{new_user.first_name} #{new_user.last_name}")
            end
            user.save!
            if csv["Role"].present?
              journals = csv["Journals"].split(',').map(&:strip)
              journals.each do |journal_name|
                journal = Journal.where(name: journal_name).first
                next unless journal.present?
                csv["Role"].split(',').map(&:strip).each do |role_name|
                  if role_name == 'Site Admin'
                    user.assign_to!(assigned_to: System.first_or_create!, role: Role.site_admin_role)
                    STDERR.puts('  made site admin')
                  elsif role_name == '-Site Admin'
                    user.resign_from!(assigned_to: System.first_or_create!, role: Role.site_admin_role)
                    STDERR.puts('  removed site admin')
                  elsif role_name == 'None' # remove all roles
                    user.assignments.destroy_all
                  elsif role_name == Role::USER_ROLE
                  # Users are assigned later
                  elsif role_name =~ /^-/ # remove roles
                    role_name = role_name[1..-1].strip # remove `-` at beginning and strip whitespace
                    user.resign_from!(assigned_to: journal, role: role_name)
                    STDERR.puts("  removed #{role_name} on #{journal.name}")
                  else # Journal roles
                    user.assign_to!(assigned_to: journal, role: role_name)
                    STDERR.puts("  made #{role_name} on #{journal.name}")
                  end
                end
              end
            end
            # Ensure User role
            user.add_user_role! unless csv["Role"].try(:strip) == 'None'
          end
        end
        puts "Successfully loaded roles for #{args[:csv_url]}"
      else
        puts "A CSV path is required. Run rake 'data:populate_initial_roles:csv[CSV_URL]' where CSV_URL is the url of the CSV file"
      end
    end
  end
end
