class RemoveMeAddFigureAttributes < ActiveRecord::Migration
  def change
    add_column :figures, :aaron, :string
  end
end
