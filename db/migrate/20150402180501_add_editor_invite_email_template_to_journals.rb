class AddEditorInviteEmailTemplateToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :editor_invite_email_template, :text
  end
end
