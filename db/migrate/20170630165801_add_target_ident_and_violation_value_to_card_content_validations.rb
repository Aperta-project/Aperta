class AddTargetIdentAndViolationValueToCardContentValidations < ActiveRecord::Migration
  def up
    add_column :card_content_validations, :target_ident, :string
    add_column :card_content_validations, :violation_value, :string
    add_index :card_content_validations, :target_ident
    add_index :card_content_validations, :violation_value
  end

  def down
    remove_column :card_content_validations, :target_ident, :string
    remove_column :card_content_validations, :violation_value, :string
    remove_index :card_content_validations, :target_ident
    remove_index :card_content_validations, :violation_value
  end
end
