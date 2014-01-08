class AddDecisionToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :decision, :string
    add_column :papers, :decision_letter, :text
  end
end
