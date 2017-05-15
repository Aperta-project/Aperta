class AddBodyToEmailLog < ActiveRecord::Migration
  def change
    add_column :email_logs, :body, :text
  end
end
