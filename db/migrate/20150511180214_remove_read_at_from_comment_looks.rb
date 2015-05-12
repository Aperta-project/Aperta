class RemoveReadAtFromCommentLooks < ActiveRecord::Migration
  def up
    remove_column :comment_looks, :read_at
  end

  def down
    add_column :comment_looks, :read_at, :datetime
  end
end
