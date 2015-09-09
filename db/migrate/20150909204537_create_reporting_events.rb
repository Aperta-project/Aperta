class CreateReportingEvents < ActiveRecord::Migration
  def change
    create_table :reporting_events do |t|
      t.string :name, null: false
      t.datetime :timestamp, null: false
      t.integer :journal_id, null: false
      t.integer :paper_id, null: false
      t.integer :record_id, null: false
      t.string :record_type, null: false
      t.string :kind, null: false
      t.jsonb :data
    end
  end
end
