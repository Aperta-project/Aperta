# Add columns to capture attachment error state during processing
class AddUrlAndErrorColumnsToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :error_message, :text
    add_column :attachments, :error_backtrace, :text
    add_column :attachments, :errored_at, :datetime
    # The pending_url is where the upload goes to be processed
    add_column :attachments, :pending_url, :string
  end
end
