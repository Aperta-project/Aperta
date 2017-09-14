class DeleteFundedAuthor < ActiveRecord::Migration
  def up
    drop_table :tahi_standard_tasks_funded_authors, if_exists: true
  end
end
