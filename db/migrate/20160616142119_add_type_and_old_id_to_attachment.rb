# Adds a single table inheritance column 'type' to attachments and defaults
# its value to AdhocAttachment since that is what this table currently
# stores. This also adds 'old_id' which is going to be used to keep
# around the old IDs as we migrate data in future migrations, should we need
# to rollback.
class AddTypeAndOldIdToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :type, :string
    add_column :attachments, :old_id, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE attachments
          SET type='AdhocAttachment', old_id=id
        SQL
      end
    end
  end
end
