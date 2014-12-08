class RemoveGhostTable < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists? 'message_participants'
      drop_table :message_participants
    end

    if ActiveRecord::Base.connection.table_exists? 'author_groups'
      drop_table :author_groups
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
