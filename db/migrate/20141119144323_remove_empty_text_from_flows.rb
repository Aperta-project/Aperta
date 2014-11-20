class RemoveEmptyTextFromFlows < ActiveRecord::Migration
  def change
    remove_column :user_flows, :empty_text, :string
    remove_column :role_flows, :empty_text, :string
  end
end
