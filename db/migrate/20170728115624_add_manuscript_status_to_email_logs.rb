class AddManuscriptStatusToEmailLogs < ActiveRecord::Migration
  def change
    add_column :email_logs, :manuscript_status, :string
    add_column :email_logs, :manuscript_version, :string
    add_reference :email_logs, :versioned_text, null: true
  end
end
