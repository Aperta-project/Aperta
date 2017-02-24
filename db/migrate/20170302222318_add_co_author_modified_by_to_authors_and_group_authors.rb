class AddCoAuthorModifiedByToAuthorsAndGroupAuthors < ActiveRecord::Migration
  def up
    add_column :authors, :co_author_state_modified_by_id, :integer
    add_column :group_authors, :co_author_state_modified_by_id, :integer
    add_foreign_key :authors, :users, column: :co_author_state_modified_by_id
    add_foreign_key :group_authors, :users, column: :co_author_state_modified_by_id
  end

  def down
    remove_foreign_key :authors, :users, column: :co_author_state_modified_by_id
    remove_foreign_key :authors, :users, column: :co_author_state_modified_by_id
    remove_column :authors, :co_author_state_modified_by_id, :integer
    remove_column :group_authors, :co_author_state_modified_by_id, :integer
  end
end
