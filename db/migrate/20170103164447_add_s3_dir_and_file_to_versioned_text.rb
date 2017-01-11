class AddS3DirAndFileToVersionedText < ActiveRecord::Migration
  def change
    add_column :versioned_texts, :s3_dir, :string
    add_column :versioned_texts, :file, :string
  end
end
