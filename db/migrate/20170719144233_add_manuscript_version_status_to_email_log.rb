class AddManuscriptVersionStatusToEmailLog < ActiveRecord::Migration
  def change
    add_column :email_logs, :manuscript_version_status, :string
  end
end
