namespace :system do
  USER_DEFAULT_PASSWORD = 'password'.freeze

  def truncate(table_name)
    ActiveRecord::Base.connection.execute("truncate #{table_name} cascade")
  end

  desc 'Initialize the system from scratch'
  task init: :environment do
    if System.initialized?
      puts 'System is already initialized.'
      # exit(1)
    end

    Rake::Task['db:migrate'].invoke
    Rake::Task['db:schema:load'].invoke

    System.init

    Rake::Task['system:user'].invoke
    Rake::Task['system:journal'].invoke

    def seed_data
      path = Rails.root.join('db', 'data.yml')
      yaml = File.read(path)

      result = {}
      YAML.load_stream(yaml) do |doc|
        key = doc.keys.first
        contents = doc[key]
        columns = contents['columns']
        records = contents['records']
        result[key] = Hash[columns.zip(records.first)]
      end
      result
    end

    puts seed_data.inspect
  end

  desc 'Create the initial site admin user'
  task user: :environment do
    puts "Creating initial user"
    # truncate('users')

    User.create!(
      username: 'admin',
      first_name: 'Adam',
      last_name: 'Administrator',
      email: 'admin@example.com',
      password: USER_DEFAULT_PASSWORD,
      password_confirmation: USER_DEFAULT_PASSWORD,
    )
  end

  desc 'Create the initial sample journal'
  task journal: :environment do
    puts "Creating sample journal"
    # truncate('journals')

    JournalFactory.create(
      name: 'The Journal of Samples',
      description: 'Sample Journal',
      logo: 'images/no-journal-image.gif',
      doi_publisher_prefix: "samplepub",
      doi_journal_prefix: 'journal.samplejournal',
      last_doi_issued: '1000010',
      staff_email: 'sample-journal-staff@example.com',
      pdf_allowed: true
    )
  end
end
