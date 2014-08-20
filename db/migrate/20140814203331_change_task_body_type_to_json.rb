class ChangeTaskBodyTypeToJson < ActiveRecord::Migration
  def change
    remove_column :tasks, :body, :string
    add_column :tasks, :body, :json
  end
end
