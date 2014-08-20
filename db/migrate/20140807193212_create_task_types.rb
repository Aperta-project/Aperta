class CreateTaskTypes < ActiveRecord::Migration
  def change
    create_table :task_types do |t|
      t.string :kind
      t.string :default_role
      t.string :default_title
    end
  end
end
