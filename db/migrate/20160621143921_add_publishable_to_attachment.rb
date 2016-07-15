# Adds the publishable column to the attachments table. This is so
# SupportingInformationFile(s) have a place to put their publishable flag.
class AddPublishableToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :publishable, :boolean
  end
end
