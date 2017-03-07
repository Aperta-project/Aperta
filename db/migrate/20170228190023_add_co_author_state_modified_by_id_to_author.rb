class AddCoAuthorStateModifiedByIdToAuthor < ActiveRecord::Migration
  def up
    add_reference :authors, :co_author_state_modified_by, foreign_key: true
  end

  def down
    remove_reference :authors, :co_author_state_modified_by
  end
end
