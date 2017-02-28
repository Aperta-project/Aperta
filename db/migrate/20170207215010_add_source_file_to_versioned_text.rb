class AddSourceFileToVersionedText < ActiveRecord::Migration
  def change
    add_column :versioned_texts, :sourcefile_s3_path, :string
    add_column :versioned_texts, :sourcefile_filename, :string
    
    rename_column :versioned_texts, :s3_dir, :manuscript_s3_path
    rename_column :versioned_texts, :file, :manuscript_filename
  end
end
