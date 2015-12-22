class CreateNewRolesAndPermissionsTables < ActiveRecord::Migration
  def change
    create_table 'assignments' do |t|
      t.integer  'user_id'
      t.integer  'role_id'
      t.integer  'assigned_to_id'
      t.string   'assigned_to_type'
      t.timestamps
    end

    create_table 'permissions' do |t|
      t.string   'action'
      t.string   'applies_to'
      t.timestamps
    end

    create_table 'permissions_roles' do |t|
      t.integer  'permission_id'
      t.integer  'role_id'
      t.timestamps
    end

    create_table 'permissions_states' do |t|
      t.integer  'permission_id'
      t.integer  'state_id'
      t.timestamps
    end

    create_table 'roles' do |t|
      t.string   'name'
      t.integer  'journal_id'
      t.boolean  'participates_in_papers', null: false, default: false
      t.boolean  'participates_in_tasks', null: false, default: false
      t.timestamps
    end

    create_table 'states' do |t|
      t.string   'name'
      t.timestamps
    end

  end
end
