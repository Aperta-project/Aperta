# adds the card_versions table and the latest_version column
# to cards as part of APERTA-9076
class AddCardVersions < ActiveRecord::Migration
  def change
    create_table :card_versions do |t|
      t.integer :version, index: true, null: false
      t.references :card, index: true, foreign_key: true
      t.references :card_content, index: true, foreign_key: true
      t.datetime :deleted_at
    end

    add_column :cards, :latest_version, :integer, null: false, default: 1
  end
end
