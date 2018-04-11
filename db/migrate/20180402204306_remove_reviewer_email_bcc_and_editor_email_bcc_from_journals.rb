class RemoveReviewerEmailBccAndEditorEmailBccFromJournals < ActiveRecord::Migration
  def change
    remove_column :journals, :reviewer_email_bcc, :string
    remove_column :journals, :editor_email_bcc, :string
  end
end
