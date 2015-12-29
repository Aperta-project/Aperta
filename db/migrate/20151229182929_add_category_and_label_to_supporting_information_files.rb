class AddCategoryAndLabelToSupportingInformationFiles < ActiveRecord::Migration
  def change
    add_column :supporting_information_files, :label, :string
    add_column :supporting_information_files, :category, :string
  end
end
