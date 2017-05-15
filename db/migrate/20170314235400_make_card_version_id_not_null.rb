class MakeCardVersionIdNotNull < ActiveRecord::Migration
  def change
    change_column :card_contents, :card_version_id, :integer, null: false
    change_column :card_versions, :card_id, :integer, null: false
  end
end
