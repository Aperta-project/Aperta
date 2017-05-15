# Add a randomly generated token to GroupAuthors
class AddTokenToGroupAuthor < ActiveRecord::Migration
  def up
    add_column :group_authors, :token, :string, unique: true
    add_column :group_authors, :co_author_state, :string
    add_column :group_authors, :co_author_state_modified, :datetime

    add_index :group_authors, [:token], unique: true

    GroupAuthor.reset_column_information
    GroupAuthor.find_each(&:migration_create_token!)

    if null_token_count("group_authors").nonzero?
      raise "Expected all GroupAuthors to have a token"
    end
  end

  def down
    remove_index :group_authors, [:token]
    remove_column :group_authors, :token
    remove_column :group_authors, :co_author_state
    remove_column :group_authors, :co_author_state_modified
  end

  # Faux class to make adding tokens easier for the migration, while
  # future-proofing the migration if `GroupAuthor` gets removed or renamed.
  class GroupAuthor < ActiveRecord::Base
    def migration_create_token!
      update_attributes! token: SecureRandom.hex(10)
    end
  end

  def null_token_count(table_name)
    column_name = "#{table_name}_count"
    sql_result = execute(<<-SQL)
      SELECT COUNT(*) as #{column_name} FROM #{table_name} WHERE TOKEN IS NULL
    SQL
    sql_result.field_values(column_name).first.to_i
  end
end
