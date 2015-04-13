class RenameSupportingInformationFilesBack < ActiveRecord::Migration
  def self.up
    rename_table :tahi_supporting_information_files, :supporting_information_files
  end
end
