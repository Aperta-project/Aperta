class DeleteCommentLooksThatHaveBeenRead < ActiveRecord::Migration
  def up
    CommentLook.where.not(read_at: nil).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
