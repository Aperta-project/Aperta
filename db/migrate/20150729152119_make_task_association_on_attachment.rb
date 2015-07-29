class MakeTaskAssociationOnAttachment < ActiveRecord::Migration
  def up
    remove_column :attachments, :attachable_type
    rename_column :attachments, :attachable_id, :task_id
  end

  def down
    rename_column :attachments, :task_id, :attachable_id
    add_column :attachments, :attachable_type, :string
  end
end
