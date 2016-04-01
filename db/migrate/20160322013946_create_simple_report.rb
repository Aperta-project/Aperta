# Adds SimpleReports table, used to track historical state information for
# reporting purposes
class CreateSimpleReport < ActiveRecord::Migration
  def change
    create_table :simple_reports do |t|
      t.timestamps
      t.integer :initially_submitted, default: 0, null: false
      t.integer :fully_submitted, default: 0, null: false
      t.integer :invited_for_full_submission, default: 0, null: false
      t.integer :checking, default: 0, null: false
      t.integer :in_revision, default: 0, null: false
      t.integer :accepted, default: 0, null: false
      t.integer :withdrawn, default: 0, null: false
      t.integer :rejected, default: 0, null: false
      t.integer :new_accepted, default: 0, null: false
      t.integer :new_rejected, default: 0, null: false
      t.integer :new_withdrawn, default: 0, null: false
      t.integer :new_initial_submissions, default: 0, null: false
      t.integer :in_process_balance, default: 0, null: false
    end
  end
end
