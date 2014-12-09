class RemoveDefaultFlagForFlows < ActiveRecord::Migration
  def change
    remove_column :flows, :default
  end
end
