class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :type
      t.references :assignee, index: true
      t.references :phase, index: true
      t.boolean :completed

      t.timestamps
    end
  end
end
