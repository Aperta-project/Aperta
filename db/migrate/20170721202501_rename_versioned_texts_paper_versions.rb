class RenameVersionedTextsPaperVersions < ActiveRecord::Migration
  def change
    rename_table :versioned_texts, :paper_versions
    rename_column :similarity_checks, :versioned_text_id, :paper_version_id
  end
end
