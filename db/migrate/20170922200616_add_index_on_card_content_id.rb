class AddIndexOnCardContentId < ActiveRecord::Migration
  def change
    add_index :content_attributes, :card_content_id
    add_index :card_contents, :card_version_id
  end
end
