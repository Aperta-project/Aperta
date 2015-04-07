class AddPublicToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :public, :boolean, default: true, null: false
  end
end
