class AddBodyToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :body, :text
  end
end
