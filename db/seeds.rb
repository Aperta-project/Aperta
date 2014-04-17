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
    first_name: 'Mike',
    last_name: 'Doel',
    password: 'skyline1',
    username: 'mikedoel',
    affiliation: 'skyline',
    admin: true)


  # create journal
  plos_journal = Journal.where(name: 'PLOS Yeti').first_or_create(logo: '')

  Paper.where(
    user_id: mike.id,
    journal_id: plos_journal.id,
    short_title: "The great scientific paper of 2014"
  ).first_or_create(
    title: "The most scrumtrulescent scientific paper of 2014.",
    abstract: "We've discovered the rain in spain tends to stay in the plain",
    body: "The quick man bear pig jumped over the fox"
  )

  mike.journal_roles.create(admin: true, reviewer: true, editor: true, journal_id: plos_journal.id)

  first_names = ['Oliver', 'Charlotte', 'Jack', 'Emily', 'James', 'Ruby', 'William', 'Sophie', 'Mason', 'Olivia', 'Richard']
  last_names  = ['Smith', 'Jones', 'Taylor', 'Brown', 'Davies', 'Evans', 'Roberts', 'Johnson', 'Robinson', 'Edwards', 'Prentice']

  # make some extra users
  (1..10).each {|i|
    u = User.create(
      first_name: first_names[i],
      last_name: last_names[i],
      email: "#{first_names[i].downcase}.#{last_names[i].downcase}@example.com",
      username: "#{first_names[i].downcase}",
      password:"password1",
      admin: true,
      affiliation:"skyline")
    u.journal_roles.create(journal_id: plos_journal.id, admin: true, editor: true, reviewer: true)
  }

  puts "Creating manuscript manager templates"
  plos_journal.manuscript_manager_templates.first_or_create(
    name: 'Default Template',
    paper_type: 'Research',
    template: {phases: [{name: 'Submission', task_types: ['AssignEditorTask', 'FigureTask']}]}
  )
end
