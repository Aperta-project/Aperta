class CreateScheduledEvents < ActiveRecord::Migration
  def change
    create_table :scheduled_events do |t|
      t.datetime :dispatch_at
      t.string :state
      t.string :name
      t.references :due_datetime, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
