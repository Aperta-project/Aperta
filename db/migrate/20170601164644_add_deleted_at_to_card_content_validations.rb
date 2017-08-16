class AddDeletedAtToCardContentValidations < ActiveRecord::Migration
  def change
    add_column :card_content_validations, :deleted_at, :datetime
    add_index :card_content_validations, :deleted_at
  end
end
