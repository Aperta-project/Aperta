# Migration to make Attachment's owner polymorphic.
class AddOwnerToAttachment < ActiveRecord::Migration
  def change
    rename_column :attachments, :task_id, :owner_id
    add_column :attachments, :owner_type, :string

    add_index :attachments, [:owner_id, :owner_type]

    reversible do |dir|
      dir.up do
        execute "UPDATE attachments SET owner_type='Task'"
      end
    end
  end
end
