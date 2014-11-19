class AddDoiInfoToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :doi, :text
  end
end
