# Add bcc email settings to journals
class AddChasingEmailsToJournal < ActiveRecord::Migration
  def change
    add_column :journals, :reviewer_email_bcc, :string
    add_column :journals, :editor_email_bcc, :string
  end
end
