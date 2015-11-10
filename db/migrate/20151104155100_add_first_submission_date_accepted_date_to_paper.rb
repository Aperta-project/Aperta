class AddFirstSubmissionDateAcceptedDateToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :first_submitted_at, :datetime
    add_column :papers, :accepted_at, :datetime
  end
end
