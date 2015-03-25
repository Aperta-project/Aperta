# This migration comes from tahi_supporting_information (originally 20150324173234)
class RenameTable < ActiveRecord::Migration
  def self.up
    rename_table :supporting_information_files, :tahi_supporting_information_files
  end

  def self.down
    rename_table :tahi_supporting_information_files, :supporting_information_files
  end
end
