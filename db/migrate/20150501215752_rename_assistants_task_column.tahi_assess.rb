# This migration comes from tahi_assess (originally 20150413231908)
class RenameAssistantsTaskColumn < ActiveRecord::Migration
  def change
    rename_column :tahi_assess_assistants, :assess_task_id, :task_id
  end
end
