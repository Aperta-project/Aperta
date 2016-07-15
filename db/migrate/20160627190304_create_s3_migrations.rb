class CreateS3Migrations < ActiveRecord::Migration
  def change
    create_table :s3_migrations do |t|
      t.text :source_url, null: false
      t.text :destination_url
      t.string :attachment_type, null: false
      t.integer :attachment_id, null: false
      t.boolean :version, null: false
      t.string :state, default: 'ready'
      t.text :error_message
      t.text :error_backtrace
      t.datetime :errored_at
      t.timestamps
    end
  end
end
