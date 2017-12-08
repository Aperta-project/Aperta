class CreateEventBehaviors < ActiveRecord::Migration
  def change
    create_table :event_behaviors do |t|
      t.string :event_name, null: false
      t.string :action, null: false
      t.references :journal, index: true, null: false
      t.timestamps null: false
    end
  end
end
