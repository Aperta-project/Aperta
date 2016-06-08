namespace :data do
  namespace :populate_initial_roles do
    require 'open-uri'
    require 'csv'
    desc "This populates the initial roles based upon a CSV file"
    task :csv, [:csv_url] => [:environment] do |t, args|
      if args[:csv_url].present?
        CSV.parse(open(args[:csv_url]), row_sep: :auto, headers: :first_row) do |csv|
          if csv["Email"].present?
            STDERR.puts("user #{csv['Email']}")
            csv["Email"] = csv["Email"].strip.downcase
            user = User.find_or_create_by(email: csv['Email'])
            user.username = csv["Email"].split('@').first.delete('.')
            user.first_name = csv["Name"].split.first if csv["Name"].try(:split).try(:count) == 2
            user.last_name = csv["Name"].split.last if csv["Name"].try(:split).try(:count) == 2
            user.auto_generate_password
            user.save!
            if csv["Role"].present?
              roles = csv["Role"].split(',')
              journals = csv["Journals"].split(',')
              journals.each do |journal_name|
                journal_name.strip!
                journal = Journal.where(name: journal_name).first
                next unless journal.present?
                roles.each do |role_name|
                  role_name.strip!
                  if role_name == 'Site Admin'
                    user.update_column(:site_admin, true)
                    STDERR.puts('  made site admin')
                  elsif role_name == 'User'
                  # Users are assigned later
                  else # Journal roles
                    Assignment.where(
                      user: user,
                      role: Role.where(name: role_name, journal: journal).first,
                      assigned_to: journal
                    ).first_or_create!
                    STDERR.puts("  made #{role_name} on #{journal.name}")
                  end
                end
              end
            end
            # Ensure User role
            Assignment.where(
              user: user,
              role: Role.where(name: 'User').first,
              assigned_to: user
            ).first_or_create!
          end
        end
        puts "Successfully loaded roles for #{args[:csv_url]}"
      else
        puts "A CSV path is required. Run rake 'data:populate_initial_roles:csv[CSV_URL]' where CSV_URL is the url of the CSV file"
      end
    end
  end
end
