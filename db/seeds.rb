class ManualSeeds # Use this class to run seeds the old way
  require 'rake'
  def self.run
    Rake::Task['db:schema:load'].invoke
    Rake::Task['data:update_journal_task_types'].invoke
    # Create Journal
    plos_journal = Journal.first_or_create!(name: 'PLOS Bio', logo: '', doi_publisher_prefix: "10.1371", doi_journal_prefix: "pbio", last_doi_issued: "0000001")

    Rake::Task['roles-and-permissions:seed'].invoke
    # Create Users
    # These Users should match Personas, by convention
    admin = User.where(email: 'admin@example.com').first_or_create! do |user|
      user.first_name = 'Admin'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'admin'
      user.site_admin = true
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(old_role: plos_journal.old_roles.where(kind: OldRole::ADMIN, name: OldRole::ADMIN.capitalize).first_or_initialize)
    end

    staff_admin = User.where(email: 'staff_admin@example.com').first_or_create! do |user|
      user.first_name = 'Staff'
      user.last_name = 'Admin'
      user.password = 'password'
      user.username = 'staff_admin'
      user.site_admin = false
      user.affiliations.first_or_initialize(name: 'PLOS')
    end
    # Assign new Staff Admin Role
    Assignment.where(
      user: staff_admin,
      role: Role.where(name: "Staff Admin").first,
      assigned_to: Journal.first
    ).first_or_create!

    User.where(email: 'editor@example.com').first_or_create! do |user|
      user.first_name = 'Editor'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'editor'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(old_role: plos_journal.old_roles.where(kind: OldRole::EDITOR, name: OldRole::EDITOR.capitalize).first_or_initialize)
    end

    User.where(email: 'reviewer@example.com').first_or_create! do |user|
      user.first_name = 'Reviewer'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'reviewer'
      user.affiliations.first_or_initialize(name: 'PLOS')
    end

    User.where(email: 'flow_manager@example.com').first_or_create! do |user|
      user.first_name = 'FlowManager'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'flow_manager'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(old_role: plos_journal.old_roles.where(kind: OldRole::FLOW_MANAGER, name: OldRole::FLOW_MANAGER.titleize).first_or_initialize)
    end

    User.where(email: 'author@example.com').first_or_create! do |user|
      user.first_name = 'Author'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'author'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.old_roles.new(journal_id: plos_journal.id, name: 'Author')
    end

    # Create Paper for Admin
    unless Paper.where(title: 'The most scrumtrulescent scientific paper of 2015.').present?
      PaperFactory.create(
        {
          journal_id:  plos_journal.id,
          short_title: 'The great scientific paper of 2015',
          title:       'The most scrumtrulescent scientific paper of 2015.',
          abstract:    'We have discovered the rain in Spain tends to stay in the plain',
          body:        'The quick man bear pig jumped over the fox',
          paper_type:  'Research'
        },
        admin
      ).save!
    end

    Rake::Task['data:update_journal_task_types'].invoke
    Rake::Task['journal:create_default_templates'].invoke
    Rake::Task['nested-questions:seed'].invoke

    puts 'Tahi Production Seeds have been loaded successfully'
  end
end

# To generate BASE seed data, run `rake db:data:dump` to dump
# the current state of the database in `db/data.yml`.

# To load data, run `rake db:data:load` to load
# the saved environment

# To save a scenario, run `rake 'data:dump:scenario[SCENARIO]'`
# To load a scenario, run `rake 'data:load:scenario[SCENARIO]'` where SCENARIO is the scenario name

if Rails.env.production?
  # don't run seeds in production
else
  ENV['PUSHER_ENABLED'] = 'false'
  Rake::Task['db:data:load'].invoke
  puts "Tahi Seeds have been loaded successfully"
end
