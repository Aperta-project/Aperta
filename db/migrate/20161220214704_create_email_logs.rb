class CreateEmailLogs < ActiveRecord::Migration
  def change
    create_table :email_logs do |t|
      t.string :from
      t.string :to
      t.string :subject
      t.string :message_id
      t.text :raw_source
      t.string :status
      t.string :error_message
      t.datetime :errored_at
      t.datetime :sent_at
      t.timestamps

      t.index :message_id
    end
  end
end
