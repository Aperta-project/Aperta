# add unique index contraint to prevent duplicate assignments
class AddUniqueIndexToAssignments < ActiveRecord::Migration
  def change
    add_index :assignments,
              [:user_id, :role_id, :assigned_to_type, :assigned_to_id],
              unique: true,
              name: 'uniq_assigment_idx'
  end
end
