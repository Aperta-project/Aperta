# As part of APERTA-5579
class AddNullFalseToPosition < ActiveRecord::Migration
  def change
    change_column :invitations, :position, :integer, null: false
  end
end
