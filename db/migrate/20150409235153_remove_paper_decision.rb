class RemovePaperDecision < ActiveRecord::Migration
  def change
    remove_column :papers, :decision
  end
end
