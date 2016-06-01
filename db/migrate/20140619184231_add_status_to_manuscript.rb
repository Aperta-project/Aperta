class AddStatusToManuscript < ActiveRecord::Migration
  def up
    add_column :manuscripts, :status, :string, default: "processing"
    execute <<-SQL
      UPDATE manuscripts SET status = 'done';
    SQL
  end

  def down
    remove_column :manuscripts, :status
  end
end
