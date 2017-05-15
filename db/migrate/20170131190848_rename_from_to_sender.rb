class RenameFromToSender < ActiveRecord::Migration
  def change
    rename_column :email_logs, :from, :sender
    rename_column :email_logs, :to, :recipients
  end
end
