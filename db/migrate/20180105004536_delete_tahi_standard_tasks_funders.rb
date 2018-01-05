class DeleteTahiStandardTasksFunders < ActiveRecord::Migration
  def up
    drop_table :tahi_standard_tasks_funders
  end
end
