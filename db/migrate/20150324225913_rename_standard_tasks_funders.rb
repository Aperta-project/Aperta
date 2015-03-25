class RenameStandardTasksFunders < ActiveRecord::Migration
  def change
    rename_table :standard_tasks_funders, :tahi_standard_tasks_funders
    rename_table :standard_tasks_funded_authors, :tahi_standard_tasks_funded_authors
  end
end
