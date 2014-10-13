class AddEditableToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :editable, :boolean, default: true
  end
end
