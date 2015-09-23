case Rails.env
when 'development'
  ENV['PUSHER_ENABLED'] = 'false'

  Rake::Task['data:create_task_types'].invoke

  # Create Journal
  plos_journal = Journal.first_or_create!(name: 'PLOS Yeti', logo: '')

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
