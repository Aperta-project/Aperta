class RenameTypeToFormatOnBibitem < ActiveRecord::Migration
  def change
    rename_column :bibitems, :type, :format
  end
end
