class AddRequiredPermissions < ActiveRecord::Migration
  def change
    create_table :permission_requirements do |t|
      t.integer :permission_id
      t.integer :required_on_id
      t.string :required_on_type
      t.timestamps null: false
    end

    add_index(
      :permission_requirements,
      [:permission_id, :required_on_id, :required_on_type],
      name: 'permission_requirements_uniq_idx',
      unique: true
    )

    remove_column :tasks, :required_permission_id, :integer
  end
end
