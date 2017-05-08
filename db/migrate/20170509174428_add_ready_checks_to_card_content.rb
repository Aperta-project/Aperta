class AddReadyChecksToCardContent < ActiveRecord::Migration
  def change
    add_column :card_contents, :ready_required_check, :string, default: nil, null: true
    add_column :card_contents, :ready_children_check, :string, default: nil, null: true
    add_column :card_contents, :ready_check, :string, default: nil, null: true
  end
end
