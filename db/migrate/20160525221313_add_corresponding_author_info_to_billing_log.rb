class AddCorrespondingAuthorInfoToBillingLog < ActiveRecord::Migration
  def change
    add_column :billing_logs, :corresponding_author_ned_id, :integer
    add_column :billing_logs, :corresponding_author_ned_email, :integer
    add_index  :billing_logs, :corresponding_author_ned_id
    add_index  :billing_logs, :corresponding_author_ned_email
  end
end
