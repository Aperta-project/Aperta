class AddUniqueIndexForVersions < ActiveRecord::Migration
  def change
    add_index :versioned_texts, [:minor_version, :major_version, :paper_id], name: 'unique_version', unique: true
  end
end
