class AddPaperSalesforceId < ActiveRecord::Migration
  def change
    add_column :papers, :salesforce_manuscript_id, :string
  end
end
