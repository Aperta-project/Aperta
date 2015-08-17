class AddSupportingInformationFilesPublishable < ActiveRecord::Migration
  def change
    add_column :supporting_information_files, :publishable, :boolean, default: true
  end
end
