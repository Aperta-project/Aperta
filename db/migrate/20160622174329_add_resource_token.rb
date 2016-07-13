# Move resource tokens into their own table
class AddResourceToken < ActiveRecord::Migration
  def up
    create_table :resource_tokens do |t|
      t.timestamps
      t.integer :owner_id
      t.string :owner_type
      t.string :token
    end

    add_index :resource_tokens, :token
    add_index :resource_tokens, [:owner_id, :owner_type]

    execute <<-SQL
      INSERT INTO resource_tokens (token, owner_id, owner_type,   created_at, updated_at)
      SELECT                       token, id,       'Attachment', created_at, created_at
      FROM attachments
    SQL
  end

  def down
    execute <<-SQL
      INSERT INTO attachments (token)
      SELECT                   token
      FROM resource_tokens
      WHERE owner_id = attachments.id AND owner_type = 'Attachment'
    SQL
    drop_table :resource_tokens
  end
end
