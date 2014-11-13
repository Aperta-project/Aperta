class AddCommentEntities < ActiveRecord::Migration
  def change
    add_column :comments, :entities, :json
  end
end
