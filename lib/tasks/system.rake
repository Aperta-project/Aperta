namespace :system do
  USER_DEFAULT_PASSWORD = 'password'.freeze
  USER_DEFAULT_EMAIL = 'admin@example.com'.freeze

  def truncate(table_name)
    ActiveRecord::Base.connection.execute("truncate #{table_name} cascade")
  end

  desc 'Initialize the system from scratch'
  task :init, [:force] => :environment do |task, args|
    if System.initialized?
      message = "The system is already initialized.\nTo force init, pass [force] on the command line."
      abort(message) unless args[:force]
    end

    puts 'Migrating schema'
    Rake::Task['db:migrate'].invoke

    puts 'Loading schema'
    Rake::Task['db:schema:load'].invoke

    puts 'Initializing system'
    System.init

    puts 'Creating initial admin user'
    Rake::Task['system:user'].invoke

    puts 'Creating sample journal'
    Rake::Task['system:journal'].invoke

    puts 'Creating default roles and permissions'
    Rake::Task['roles-and-permissions:seed'].invoke

    puts 'Assigning site admin role'
    Rake::Task['roles-and-permissions:assign_site_admin'].invoke(USER_DEFAULT_EMAIL)

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

    # puts seed_data.inspect
  end

  desc 'Create the initial site admin user'
  task user: :environment do
    truncate('users')

    User.create!(
      username: 'admin',
      first_name: 'Adam',
      last_name: 'Administrator',
      email: USER_DEFAULT_EMAIL,
      password: USER_DEFAULT_PASSWORD,
      password_confirmation: USER_DEFAULT_PASSWORD,
    )

  end

  desc 'Create the initial sample journal'
  task journal: :environment do
    truncate('cards')
    truncate('journals')

    journal = JournalFactory.create(
      name: 'The Journal of Samples',
      description: 'Sample Journal',
      logo: 'images/no-journal-image.gif',
      doi_publisher_prefix: "samplepub",
      doi_journal_prefix: 'journal.samplejournal',
      last_doi_issued: '1000010',
      staff_email: 'sample-journal-staff@example.com',
      pdf_allowed: true
    )

    puts 'Loading custom cards'
    start = Time.now
    CustomCard::FileLoader.load(journal)
    time = Time.now - start
    count = Card.count
    puts "#{count} custom #{'card'.pluralize(count)} loaded in #{time.round} seconds."
  end
end
