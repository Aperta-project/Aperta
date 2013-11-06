class AddUsernameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :username, :string
    add_index :users, :username, unique: true

    execute "UPDATE users SET username = LOWER(id || first_name || last_name)"
    change_column_null :users, :username, true
  end

  def down
    remove_column :users, :username
  end
end
