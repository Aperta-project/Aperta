class RevertToggleableAndRollbackAttributes < ActiveRecord::Migration
  def change
    remove_column :card_contents, :revert_children_on_hide, :boolean
    remove_column :card_content_validations, :target_ident, :string
    remove_column :card_content_validations, :violation_value, :string
    end
end
