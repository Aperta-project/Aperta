# Adds the label column to the attachments table. This is so
# SupportingInformationFile(s) have a place to put their label.
class AddLabelToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :label, :string
  end
end
