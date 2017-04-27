class AddUploadColumnsToCardContent < ActiveRecord::Migration
  def change
    add_column :card_contents, :allow_multiple_uploads, :boolean
    add_column :card_contents, :allow_file_captions, :boolean
  end
end
