class ChangeQueryToHstore < ActiveRecord::Migration
  def change
    remove_column :flows, :query, :text
    add_column :flows, :query, :hstore
  end
end
