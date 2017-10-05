class ChangeTextContentTypeToDescription < ActiveRecord::Migration
  def up
    execute "UPDATE card_contents SET content_type='description' WHERE content_type='text'"
  end

  def down
    execute "UPDATE card_contents SET content_type='text' WHERE content_type='description'"
  end
end
