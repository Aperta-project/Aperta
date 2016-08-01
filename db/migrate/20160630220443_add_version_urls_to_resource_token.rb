# ResourceToken holds all the url information directly
class AddVersionUrlsToResourceToken < ActiveRecord::Migration
  def change
    add_column :resource_tokens, :version_urls, :jsonb, null: false, default: '{}'
    add_column :resource_tokens, :default_url, :string
  end
end
