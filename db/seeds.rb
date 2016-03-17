class ManualSeeds #Use this class to run seeds the old way
  def run
    Rake::Task['data:update_journal_task_types'].invoke
    # Create Journal
    plos_journal = Journal.first_or_create!(name: 'PLOS Yeti', logo: '', doi_publisher_prefix: "yetipub", doi_journal_prefix: "yetijour", last_doi_issued: "1000000")

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
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::ADMIN, name: OldRole::ADMIN.capitalize).first_or_initialize)
    end

    site_admin = User.where(email: 'site_admin@example.com').first_or_create! do |user|
      user.first_name = 'Steve'
      user.last_name = 'SiteAdmin'
      user.password = 'password'
      user.username = 'site_admin'
      user.site_admin = true
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::ADMIN, name: OldRole::ADMIN.capitalize).first_or_initialize)
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
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::EDITOR, name: OldRole::EDITOR.capitalize).first_or_initialize)
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
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::FLOW_MANAGER, name: OldRole::FLOW_MANAGER.titleize).first_or_initialize)
    end

    User.where(email: 'author@example.com').first_or_create! do |user|
      user.first_name = 'Author'
      user.last_name = 'User'
      user.password = 'password'
      user.username = 'author'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.old_roles.new(journal_id: plos_journal.id, name: 'Author')
    end

    # QA Users
    qa_admin = User.where(email: 'sealresq+7@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey SA'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_sa'
      user.site_admin = true
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::ADMIN, name: OldRole::ADMIN.capitalize).first_or_initialize)
    end

    qa_ordinary_admin = User.where(email: 'sealresq+6@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey OA'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_oa'
      user.site_admin = false
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::ADMIN, name: OldRole::ADMIN.capitalize).first_or_initialize)
    end

    qa_flow_manager = User.where(email: 'sealresq+5@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey FM'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_flowmgr'
      user.site_admin = false
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::FLOW_MANAGER, name: OldRole::FLOW_MANAGER.titleize).first_or_initialize)
    end

    qa_editor = User.where(email: 'sealresq+4@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey AMM'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_editor'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::EDITOR, name: OldRole::EDITOR.capitalize).first_or_initialize)
    end

    qa_editor2 = User.where(email: 'sealresq+3@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey MM'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_assoceditor'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(kind: OldRole::EDITOR, name: OldRole::EDITOR.capitalize).first_or_initialize)
    end

    qa_reviewer = User.where(email: 'sealresq+2@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey RV'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_reviewer'
      user.affiliations.first_or_initialize(name: 'PLOS')
    end

    qa_author = User.where(email: 'sealresq+1@gmail.com').first_or_create! do |user|
      user.first_name = 'Jeffrey AU'
      user.last_name = 'Gray'
      user.password = 'in|fury8'
      user.username = 'jgray_author'
      user.affiliations.first_or_initialize(name: 'PLOS')
      user.user_roles.new(role: plos_journal.old_roles.where(name: 'Author').first_or_initialize)
    end

    # Create Papers for QA
    unless Paper.where(title: 'Hendrik a011f9d4-0119-4611-88af-9838ff154cec').present?
      PaperFactory.create(
        {
          journal_id:  plos_journal.id,
          short_title: 'Hendrik a011f9d4-0119-4611-88af-9838ff154cec',
          title:       'Hendrik a011f9d4-0119-4611-88af-9838ff154cec',
          abstract:    'We have discovered the rain in Spain tends to stay in the plain',
          body:        'The quick man bear pig jumped over the fox',
          paper_type:  'Research'
        },
        qa_admin
      ).save!
    end

    unless Paper.where(title: 'Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5').present?
      PaperFactory.create(
        {
          journal_id:  plos_journal.id,
          short_title: 'Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5',
          title:       'Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5',
          abstract:    'We have discovered the rain in Spain tends to stay in the plain',
          body:        'The quick man bear pig jumped over the fox',
          paper_type:  'Research'
        },
        qa_admin
      ).save!
    end

    # Create Paper for Admin
    unless Paper.where(title: 'The most scrumtrulescent scientific paper of 2015.').present?
      PaperFactory.create(
        {
          journal_id:  plos_journal.id,
          short_title: 'The great scientific paper of 2015',
          title:       'The most scrumtrulescent scientific paper of 2015.',
          abstract:    'We have discovered the rain in Spain tends to stay in the plain',
          body:        Paper.first.body,
          paper_type:  'Research'
        },
        admin
      ).save!
    end

    Rake::Task['data:update_journal_task_types'].invoke
    Rake::Task['journal:create_default_templates'].invoke
    Rake::Task['nested-questions:seed'].invoke

    puts 'Tahi Seeds have been loaded successfully'
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
