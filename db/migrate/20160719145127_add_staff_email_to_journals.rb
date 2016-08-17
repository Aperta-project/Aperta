class AddStaffEmailToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :staff_email, :string
  end
end
