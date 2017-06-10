class AddExternalCorrespondenceFieldsToEmailLogs < ActiveRecord::Migration
  def change
    add_column :email_logs, :type, :string
    add_column :email_logs, :description, :string
    add_column :email_logs, :cc, :string
    add_column :email_logs, :bcc, :string
  end
end
