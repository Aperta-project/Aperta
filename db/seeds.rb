case Rails.env
when 'development'
  Rake::Task['data:create_task_types'].invoke

  # create admin user
  mike = User.where(email: 'mikedoel@neo.com').first_or_create(
    first_name:  'Mike',
    last_name:   'Doel',
    password:    'skyline1',
    username:    'mikedoel',
    site_admin:       true
  )

  mike.affiliations.first_or_create(name: "skyline")

  # create journal
  plos_journal = Journal.first_or_create(name: 'PLOS Yeti', logo: '')

  paper = Paper.where(
    user_id: mike.id,
    journal_id: plos_journal.id,
    short_title: "The great scientific paper of 2014"
  ).first
  unless paper
    paper_params = {
      user_id:     mike.id,
      journal_id:  plos_journal.id,
      short_title: "The great scientific paper of 2014",
      title:       "The most scrumtrulescent scientific paper of 2014.",
      abstract:    "We've discovered the rain in spain tends to stay in the plain",
      body:        "The quick man bear pig jumped over the fox"
    }
    paper = PaperFactory.create(paper_params, mike)
  end

  mike.roles.create(journal_id: plos_journal.id)

  first_names = ['Oliver', 'Charlotte', 'Jack', 'Emily', 'James', 'Ruby', 'William', 'Sophie', 'Mason', 'Olivia', 'Richard']
  last_names  = ['Smith', 'Jones', 'Taylor', 'Brown', 'Davies', 'Evans', 'Roberts', 'Johnson', 'Robinson', 'Edwards', 'Prentice']

  # make some extra users
  (1..10).each {|i|
    u = User.create(
      first_name:  first_names[i],
      last_name:   last_names[i],
      email:       "#{first_names[i].downcase}.#{last_names[i].downcase}@example.com",
      username:    "#{first_names[i].downcase}",
      password:    "password1",
      site_admin:       true
    )
    if u.persisted?
      u.roles.create!(journal_id: plos_journal.id, name: "Role #{i}")
      u.affiliations.create!(name: "Affiliation #{i}")
    end
  }
  Rake::Task['data:create_task_types'].invoke
  Rake::Task['journal:create_default_templates'].invoke
end
