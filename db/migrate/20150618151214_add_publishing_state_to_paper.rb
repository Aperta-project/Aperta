class AddPublishingStateToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :publishing_state, :string
    add_index :papers, :publishing_state
  end
end
