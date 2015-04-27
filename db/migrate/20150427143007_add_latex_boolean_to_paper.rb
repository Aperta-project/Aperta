class AddLatexBooleanToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :latex, :boolean, default: false
  end
end
