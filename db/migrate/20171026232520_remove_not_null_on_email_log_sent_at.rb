class RemoveNotNullOnEmailLogSentAt < ActiveRecord::Migration
  def change
    # reverses 20171018192303_change_correspondence_sent_at
    change_column :email_logs, :sent_at, :datetime, null: true
  end
end
