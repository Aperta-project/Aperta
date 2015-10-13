class AddEmGuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :em_guid, :string
  end
end
