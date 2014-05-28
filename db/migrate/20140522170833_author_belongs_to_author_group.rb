class AuthorBelongsToAuthorGroup < ActiveRecord::Migration
  def change
    rename_column :authors, :paper_id, :author_group_id
  end
end
