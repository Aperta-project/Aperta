class AddManuscriptStatusToEmailLog < ActiveRecord::Migration
  def change
    add_column :email_logs, :manuscript_status, :string
  end
end
