class CreatePhases < ActiveRecord::Migration
  def change
    create_table :phases do |t|
      t.belongs_to :task_manager, index: true
      t.string :name

      t.timestamps
    end
  end
end
