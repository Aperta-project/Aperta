class UniqueDecisions < ActiveRecord::Migration
  def change
    add_index :decisions, [:minor_version, :major_version, :paper_id], name: 'unique_decision_version', unique: true
  end
end
