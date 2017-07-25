class AddManuscriptVersionToEmailLog < ActiveRecord::Migration
  def change
    add_column :email_logs, :manuscript_version, :string
  end
end
