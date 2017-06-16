class AddExternalFieldsToCorrespondence < ActiveRecord::Migration
  def change
    add_column :email_logs, :external, :boolean
    add_column :email_logs, :description, :string
    add_column :email_logs, :cc, :string
    add_column :email_logs, :bcc, :string
  end
end
