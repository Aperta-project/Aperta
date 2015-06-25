class RemoveAuthorGroups < ActiveRecord::Migration
  def up
    add_column :authors, :paper_id, :integer
    remove_column :authors, :author_group_id
    drop_table    :author_groups
    create_table  :author_paper
  end

  def down
    # irreversible
    raise ActiveRecord::IrreversibleMigration, "Can't recover author groups information."
  end
end
