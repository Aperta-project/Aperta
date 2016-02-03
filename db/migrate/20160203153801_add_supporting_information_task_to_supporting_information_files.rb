# rubocop:disable all
class AddSupportingInformationTaskToSupportingInformationFiles < ActiveRecord::Migration
  def change
    # Using 'si_task_id' instead of 'supporting_information_task_id' because a
    # chars limit in the index names
    add_column :supporting_information_files, :si_task_id,
               :integer
    add_index :supporting_information_files, :si_task_id
  end
end
