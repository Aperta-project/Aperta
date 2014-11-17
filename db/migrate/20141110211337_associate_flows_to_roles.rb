class AssociateFlowsToRoles < ActiveRecord::Migration
  def change
    add_reference :flows, :role, index: true
  end
end
