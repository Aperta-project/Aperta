class RenameFinancialDisclosureStuff < ActiveRecord::Migration
  def change
    rename_table :financial_disclosure_funded_authors, :standard_tasks_funded_authors
    rename_table :financial_disclosure_funders, :standard_tasks_funders
  end
end
