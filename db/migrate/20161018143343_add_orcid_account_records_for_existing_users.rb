# For ease and simplification of implementation all users are given an
# OrcidAccount db record regardless if they have connected to orcid or not.
class AddOrcidAccountRecordsForExistingUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO orcid_accounts (user_id, created_at, updated_at)
      SELECT                      id,      NOW(),      NOW()
      FROM users;
    SQL
  end

  def down
    execute "DELETE FROM orcid_accounts"
  end
end
