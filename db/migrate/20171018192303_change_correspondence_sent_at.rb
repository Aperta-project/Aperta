class ChangeCorrespondenceSentAt < ActiveRecord::Migration
  def change
    change_column :email_logs, :sent_at, :datetime, null: false
  end
end
