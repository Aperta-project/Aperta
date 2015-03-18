class AddGinIndexesToUserSearchableFields < ActiveRecord::Migration
  def up
    execute "create index users_first_name on users using gin(to_tsvector('english', first_name));"
    execute "create index users_last_name on users using gin(to_tsvector('english', last_name));"
    execute "create index users_email on users using gin(to_tsvector('english', email));"
    execute "create index users_username on users using gin(to_tsvector('english', username));"
  end

  def down
    execute "drop index users_first_name"
    execute "drop index users_last_name"
    execute "drop index users_email"
    execute "drop index users_username"
  end
end
