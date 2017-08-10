class CreateScheduledEventTemplates < ActiveRecord::Migration
  def change
    create_table :scheduled_event_templates do |t|
      t.string :owner
      t.integer :owner_id
      t.string :event_name
      t.integer :event_dispatch_offset
      t.references :due_datetime, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
