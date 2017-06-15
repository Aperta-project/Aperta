class ChangeEmailLogsTypeToFlag < ActiveRecord::Migration
  def change
    remove_column :email_logs, :type, :string
    add_column    :email_logs, :external, :boolean, default: false
  end
end
