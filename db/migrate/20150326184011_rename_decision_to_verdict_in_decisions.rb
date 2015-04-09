class RenameDecisionToVerdictInDecisions < ActiveRecord::Migration
  def change
    rename_column :decisions, :decision, :verdict
  end
end
