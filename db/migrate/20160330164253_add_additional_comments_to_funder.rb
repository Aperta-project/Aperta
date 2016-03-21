# Adding an additional field to funder to help express non-standard funder cases
class AddAdditionalCommentsToFunder < ActiveRecord::Migration
  def change
    add_column :tahi_standard_tasks_funders, :additional_comments, :text
  end
end
