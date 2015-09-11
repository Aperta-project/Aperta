class AddActiveToPapers < ActiveRecord::Migration
  def up
    add_column :papers, :active, :boolean, default: true
    Paper.where(publishing_state: 'withdrawn').update_all(active: false)
    Paper.where(publishing_state: 'rejected').update_all(active: false)
  end

  def down
    remove_column :papers, :active
  end
end
