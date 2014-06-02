# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#

case Rails.env
when 'development'
  # create admin user
  mike = User.where(email: 'mikedoel@neo.com').first_or_create(
    first_name:  'Mike',
    last_name:   'Doel',
    password:    'skyline1',
    username:    'mikedoel',
    admin:       true
  )

  mike.affiliations.first_or_create(name: "skyline")

  # create journal
  plos_journal = Journal.where(name: 'PLOS Yeti').first
  unless plos_journal
    plos_journal = Journal.create(name: 'PLOS Yeti', logo: '')
  end

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

  mike.journal_roles.create(journal_id: plos_journal.id)

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
      admin:       true
    )
    if u.persisted?
      u.journal_roles.create!(journal_id: plos_journal.id)
      u.affiliations.create!(name: "Affiliation #{i}")
    end
  }
end
