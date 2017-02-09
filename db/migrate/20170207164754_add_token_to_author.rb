class AddTokenToAuthor < ActiveRecord::Migration
  def up
    add_column :authors, :token, :string, unique: true
    add_column :authors, :co_author_state, :string
    add_column :authors, :co_author_state_modified, :datetime

    add_index :authors, [:token], unique: true

    Author.find_each(&:migration_create_token!)
  end

  def down
    remove_index :authors, [:token]
    remove_column :authors, :token
    remove_column :authors, :co_author_state
    remove_column :authors, :co_author_state_modified
  end

  # Faux class to make adding tokens easier for the migration, while
  # future-proofing the migration if `Author` gets removed or renamed.
  class Author < ActiveRecord::Base
    def migration_create_token!
      update_attributes! token: SecureRandom.hex(10)
    end
  end
end
