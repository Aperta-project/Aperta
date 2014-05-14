class CreateCommentLooks < ActiveRecord::Migration
  def change
    create_table :comment_looks do |t|
      t.references :user,    index: true
      t.references :comment, index: true
      t.datetime   :read_at, default: nil

      t.timestamps
    end
  end
end
