class AddStatusToSupportingInfoFile < ActiveRecord::Migration
  def change
    add_column :supporting_information_files, :status, :string, default: "processing"
  end
end
