# VersionedTexts no longer holds the source for the manuscripts
# That responsibility has moved to ManuscriptAttachment
class RemoveSourceFromVersionedText < ActiveRecord::Migration
  def up
    remove_column :versioned_texts, :source
  end

  def down
    add_column :versioned_texts, :source, :string
  end
end
