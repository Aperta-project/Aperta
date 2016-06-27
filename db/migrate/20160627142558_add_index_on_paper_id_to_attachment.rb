class AddIndexOnPaperIdToAttachment < ActiveRecord::Migration
  def change
    add_index :attachments, :paper_id
  end
end
