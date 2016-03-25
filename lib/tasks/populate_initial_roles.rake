namespace :data do
  namespace :populate_initial_roles do
    require 'open-uri'
    require 'csv'
    desc "This populates the initial roles based upon a CSV file"
    task :csv, [:csv_name] => [:environment] do |t, args|
      if args[:csv_url].present?
        CSV.new(open(args[:csv_url]), headers: :first_row).each do |line|
          puts line
          puts line[0]
        end
        puts "Successfully loaded roles for #{args[:csv_name]}"
      else
        puts "A CSV path is required. Run rake 'data:populate_initial_roles:csv[CSV_URL]' where CSV_URL is the url of the CSV file"
      end
    end
  end
end
