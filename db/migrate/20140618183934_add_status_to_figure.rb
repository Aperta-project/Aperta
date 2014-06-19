class AddStatusToFigure < ActiveRecord::Migration
  def change
    add_column :figures, :status, :string, default: "processing"
  end
end
