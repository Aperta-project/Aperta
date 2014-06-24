# This migration comes from financial_disclosure (originally 20140618180941)
class CreateFinancialDisclosureFunders < ActiveRecord::Migration
  def change
    create_table :financial_disclosure_funders do |t|
      t.string :name
      t.string :grant_number
      t.string :website
      t.boolean :funder_had_influence
      t.text :funder_influence_description
      t.references :task, index: true
      t.timestamps
    end

    create_table :financial_disclosure_funded_authors do |t|
      t.references :author, index: true
      t.references :funder, index: true
    end

    add_index :financial_disclosure_funded_authors, [:author_id, :funder_id], 
      unique: true, name: "funded_authors_unique_index"
  end
end

