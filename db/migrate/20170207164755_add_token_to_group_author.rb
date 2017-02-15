class AddTokenToGroupAuthor < ActiveRecord::Migration
  def up
    add_column :group_authors, :token, :string, unique: true
    add_column :group_authors, :co_author_state, :string
    add_column :group_authors, :co_author_state_modified, :datetime

    add_index :group_authors, [:token], unique: true

    GroupAuthor.reset_column_information
    GroupAuthor.find_each(&:migration_create_token!)
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
end
