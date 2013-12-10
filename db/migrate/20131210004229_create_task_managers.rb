class CreateTaskManagers < ActiveRecord::Migration
  def change
    create_table :task_managers do |t|
      t.belongs_to :paper, index: true

      t.timestamps
    end
  end
end
