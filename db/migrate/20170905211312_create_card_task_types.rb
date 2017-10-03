class CreateCardTaskTypes < ActiveRecord::Migration
  def change
    create_table :card_task_types do |t|
      t.string :display_name
      t.string :task_class
    end

    add_reference :cards, :card_task_type, index: true
  end
end
