class ConstrainRevisionNumberOnDecisions < ActiveRecord::Migration
  def change
    add_index :decisions, [:paper_id, :revision_number], unique: true
  end
end
