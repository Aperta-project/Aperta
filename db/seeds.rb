case Rails.env
when 'development'
  Rake::Task['data:create_task_types'].invoke

  # Create Journal
  plos_journal = Journal.first_or_create(name: 'PLOS Yeti', logo: '')

  # Create Users
  # These Users should match Personas, by convention
  admin = User.where(email: 'admin@example.com').first_or_create(
    first_name: 'Admin',
    last_name:  'User',
    password:   'password',
    username:   'admin',
    site_admin: true
  )
  if admin.new_record?
    admin.affiliations.first_or_create(name: "PLOS")
    admin.roles.create!(journal_id: plos_journal.id, name: "Role admin", kind: Role::ADMIN)
  end

  editor = User.where(email: 'editor@example.com').first_or_create(
    first_name: 'Editor',
    last_name:  'User',
    password:   'password',
    username:   'editor'
  )
  if admin.new_record?
    editor.affiliations.first_or_create(name: "PLOS")
    editor.roles.create!(journal_id: plos_journal.id, name: "Role editor", kind: Role::EDITOR)
  end

  reviewer = User.where(email: 'reviewer@example.com').first_or_create(
    first_name: 'Reviewer',
    last_name:  'User',
    password:   'password',
    username:   'reviewer'
  )
  if reviewer.new_record?
    reviewer.affiliations.first_or_create(name: "PLOS")
    reviewer.roles.create!(journal_id: plos_journal.id, name: "Role reviewer", kind: Role::REVIEWER)
  end

  flow_manager = User.where(email: 'flow_manager@example.com').first_or_create(
    first_name: 'FlowManager',
    last_name:  'User',
    password:   'password',
    username:   'flow_manager'
  )
  if flow_manager.new_record?
    flow_manager.affiliations.first_or_create(name: "PLOS")
    flow_manager.roles.create!(journal_id: plos_journal.id, name: "Role flow_manager", kind: Role::FLOW_MANAGER)
  end

  author = User.where(email: 'author@example.com').first_or_create(
    first_name: 'Author',
    last_name:  'User',
    password:   'password',
    username:   'author'
  )
  if author.new_record?
    author.affiliations.first_or_create(name: "PLOS")
    author.roles.create!(journal_id: plos_journal.id, name: "Role author")
  end

  # Create Paper for Admin

  unless Paper.where(short_title: "The great scientific paper of 2015").present?
    PaperFactory.create(
      {
        journal_id:  plos_journal.id,
        short_title: "The great scientific paper of 2015",
        title:       "The most scrumtrulescent scientific paper of 2015.",
        abstract:    "We've discovered the rain in Spain tends to stay in the plain",
        body:        "The quick man bear pig jumped over the fox",
        paper_type:  "editable"
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
    u = User.where(email: email).first_or_create(
      first_name: first_name,
      last_name:  last_name,
      username:   "#{first_name.downcase}",
      password:   "password"
    )
    if u.new_record?
      u.roles.create!(journal_id: plos_journal.id, name: "Role #{i}")
      u.affiliations.create!(name: "Affiliation #{i}")
    end
  }

  Rake::Task['data:create_task_types'].invoke
  Rake::Task['journal:create_default_templates'].invoke

  p "Tahi Seeds have been loaded successfully"
end
