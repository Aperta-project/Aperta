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

  mike.journal_roles.create(admin: true, journal_id: plos_journal.id)

end
