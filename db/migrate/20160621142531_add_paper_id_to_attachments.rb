# Adds paper_id column to the attachments table and sets it
# accordingly based on the current owner_id and owner_type
class AddPaperIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :paper_id, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE attachments
          SET paper_id=owner_id
          WHERE owner_type='Paper'
        SQL

        execute <<-SQL
          UPDATE attachments
          SET paper_id=tasks.paper_id
          FROM tasks
          WHERE tasks.id=attachments.owner_id AND attachments.owner_type='Task'
        SQL
      end
    end
  end
end
