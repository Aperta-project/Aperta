unless defined? TaskManager
  class TaskManager < ActiveRecord::Base
  end
end

class DropTaskManagers < ActiveRecord::Migration
  def up
    add_column :phases, :paper_id, :integer # can't null false without a default
    TaskManager.all.each do |tm|
      Phase.where(task_manager_id: tm.id).update_all(paper_id: tm.paper_id)
    end
    change_column :phases, :paper_id, :integer, null: false
    add_index :phases, :paper_id
    remove_column :phases, :task_manager_id
    drop_table :task_managers
  end
end
