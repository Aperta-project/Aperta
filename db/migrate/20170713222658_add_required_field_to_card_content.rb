class AddRequiredFieldToCardContent < ActiveRecord::Migration
  def change
    add_column :card_contents, :required_field, :boolean, default: false
  end
end
