class CreateDecisions < ActiveRecord::Migration
  def change
    create_table :decisions do |t|
      t.references :paper, index: true
      t.integer :revision_number, default: 0
      t.text :letter
      t.string :decision
      t.timestamps
    end
    add_foreign_key :decisions, :papers
  end
end
