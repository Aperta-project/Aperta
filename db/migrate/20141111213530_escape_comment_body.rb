class EscapeCommentBody < ActiveRecord::Migration
  def change
    Comment.all.each do |comment|
      comment.escape_body
      comment.save
    end
  end
end
