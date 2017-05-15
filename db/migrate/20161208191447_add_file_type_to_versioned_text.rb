class AddFileTypeToVersionedText < ActiveRecord::Migration
  def change
    add_column :versioned_texts, :file_type, :string
  end
end
