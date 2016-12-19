class AllowDuplicatePublisherPrefixes < ActiveRecord::Migration
  def change
    remove_index :journals, :doi_publisher_prefix
  end
end
