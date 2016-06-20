# In zsh, this is run as `rake 'db:import[SOURCEDB]'` where SOURCEDB is the heroku address or
# `rake db:import` for the tahi-staging db default

namespace :db do
  desc "Import data from staging environment"
  task :heroku_import, [:source_db_name] => [:environment] do |t, args|
    fail "This can only be run in a development environment" unless Rails.env.development?
    source_db = args[:source_db_name].present? ? args[:source_db_name] : 'tahi-staging'
    Rake::Task['db:drop'].invoke
    system("`(heroku pg:pull DATABASE_URL tahi_development --app #{source_db}) && rake db:reset_passwords`")
  end

  task :reset_passwords => [:environment] do |t, args|
    fail "This can only be run in a development environment" unless Rails.env.development?
    Journal.update_all(logo: nil)
    User.update_all(avatar: nil)
    User.all.each do |u|
      u.password = "password" # must be set explicitly
      u.save
    end
  end
end
