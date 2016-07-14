# Adds the category column to the attachments table. This is so
# SupportingInformationFile(s) have a place to put their category.
class AddCategoryToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :category, :string
  end
end
