case Rails.env
when 'development'
  ENV['PUSHER_ENABLED'] = 'false'

  Rake::Task['data:create_task_types'].invoke

  # Create Journal
  plos_journal = Journal.first_or_create!(name: 'PLOS Yeti', logo: '')

  FactoryGirl.create(:manuscript_manager_template, journal: plos_journal, paper_type: "No Flows")

  # Create Users
  # These Users should match Personas, by convention
  admin = User.where(email: 'admin@example.com').first_or_create! do |user|
    user.first_name = 'Admin'
    user.last_name = 'User'
    user.password = 'password'
    user.username = 'admin'
    user.site_admin = true
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::ADMIN, name: Role::ADMIN.capitalize).first_or_initialize)
  end

  User.where(email: 'editor@example.com').first_or_create! do |user|
    user.first_name = 'Editor'
    user.last_name = 'User'
    user.password = 'password'
    user.username = 'editor'
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::EDITOR, name: Role::EDITOR.capitalize).first_or_initialize)
  end

  User.where(email: 'reviewer@example.com').first_or_create! do |user|
    user.first_name = 'Reviewer'
    user.last_name = 'User'
    user.password = 'password'
    user.username = 'reviewer'
    user.affiliations.first_or_initialize(name: "PLOS")
  end

  User.where(email: 'flow_manager@example.com').first_or_create! do |user|
    user.first_name = 'FlowManager'
    user.last_name = 'User'
    user.password = 'password'
    user.username = 'flow_manager'
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::FLOW_MANAGER, name: Role::FLOW_MANAGER.capitalize).first_or_initialize)
  end

  User.where(email: 'author@example.com').first_or_create! do |user|
    user.first_name = 'Author'
    user.last_name = 'User'
    user.password = 'password'
    user.username = 'author'
    user.affiliations.first_or_initialize(name: "PLOS")
    user.roles.new(journal_id: plos_journal.id, name: "Author")
  end

  # QA Users
  # rubocop:disable Lint/UselessAssignment
  qa_admin = User.where(email: 'sealresq+7@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey SA'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_sa'
    user.site_admin = true
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::ADMIN, name: Role::ADMIN.capitalize).first_or_initialize)
  end

  qa_ordinary_admin = User.where(email: 'sealresq+6@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey OA'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_oa'
    user.site_admin = false
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::ADMIN, name: Role::ADMIN.capitalize).first_or_initialize)
  end

  qa_flow_manager = User.where(email: 'sealresq+5@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey FM'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_flowmgr'
    user.site_admin = false
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::FLOW_MANAGER, name: Role::FLOW_MANAGER.capitalize).first_or_initialize)
  end

  qa_editor = User.where(email: 'sealresq+4@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey AMM'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_editor'
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::EDITOR, name: Role::EDITOR.capitalize).first_or_initialize)
  end

  qa_editor2 = User.where(email: 'sealresq+3@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey MM'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_assoceditor'
    user.affiliations.first_or_initialize(name: "PLOS")
    user.user_roles.new(role: plos_journal.roles.where(kind: Role::EDITOR, name: Role::EDITOR.capitalize).first_or_initialize)
  end

  qa_reviewer = User.where(email: 'sealresq+2@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey RV'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_reviewer'
    user.affiliations.first_or_initialize(name: "PLOS")
  end

  qa_author = User.where(email: 'sealresq+1@gmail.com').first_or_create! do |user|
    user.first_name = 'Jeffrey AU'
    user.last_name = 'Gray'
    user.password = 'in|fury8'
    user.username = 'jgray_author'
    user.affiliations.first_or_initialize(name: "PLOS")
    user.roles << Role.where(name: "Author").first
  end
  # rubocop:enable Lint/UselessAssignment

  # Create Papers for QA
  unless Paper.where(short_title: "Hendrik a011f9d4-0119-4611-88af-9838ff154cec").present?
    PaperFactory.create(
      {
        journal_id:  plos_journal.id,
        short_title: "Hendrik a011f9d4-0119-4611-88af-9838ff154cec",
        title:       "Hendrik a011f9d4-0119-4611-88af-9838ff154cec",
        abstract:    "We've discovered the rain in Spain tends to stay in the plain",
        body:        "<p>The quick man bear pig jumped over the fox</p>",
        paper_type:  "Research"
      },
      qa_admin
    ).save!
  end

  unless Paper.where(short_title: "Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5").present?
    PaperFactory.create(
      {
        journal_id:  plos_journal.id,
        short_title: "Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5",
        title:       "Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5",
        abstract:    "We've discovered the rain in Spain tends to stay in the plain",
        body:        "<p>The quick man bear pig jumped over the fox</p>",
        paper_type:  "Research"
      },
      qa_admin
    ).save!
  end

  # Create Paper for Admin
  unless Paper.where(short_title: "The great scientific paper of 2015").present?
    PaperFactory.create(
      {
        journal_id:  plos_journal.id,
        short_title: "The great scientific paper of 2015",
        title:       "The most scrumtrulescent scientific paper of 2015.",
        abstract:    "We've discovered the rain in Spain tends to stay in the plain",
        body:        "<p>The quick man bear pig jumped over the fox</p>",
        paper_type:  "Research"
      },
      admin
    ).save!
  end

  # Create additional Admin Users
  names = [
    ["Oliver", "Smith"],
    ["Charlotte", "Jones"],
    ["Jack", "Taylor"],
    ["Emily", "Brown"],
    ["James", "Davies"],
    ["Ruby", "Evans"],
    ["William", "Roberts"],
    ["Sophie", "Johnson"],
    ["Mason", "Robinson"],
    ["Olivia", "Edwards"],
    ["Richard", "Prentice"]
  ]

  names.each_with_index { |name, i|
    first_name = name[0]
    last_name = name[1]

    email = "#{first_name.downcase}.#{last_name.downcase}@example.com"
    User.where(email: email).first_or_create! do |user|
      user.first_name = first_name
      user.last_name = last_name
      user.username = "#{first_name.downcase}"
      user.password = "password"
      user.roles.new(journal_id: plos_journal.id, name: "Role #{i}")
      user.affiliations.new(name: "Affiliation #{i}")
    end
  }

  FactoryGirl.create(:flow)

  Rake::Task['data:create_task_types'].invoke
  Rake::Task['journal:create_default_templates'].invoke

  puts "Tahi Seeds have been loaded successfully"
end
