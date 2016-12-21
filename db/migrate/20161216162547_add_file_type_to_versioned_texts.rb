class AddFileTypeToVersionedTexts < ActiveRecord::Migration
  def change
    add_column :versioned_texts, :file_type, :string, :default => 'docx'
  end
end
