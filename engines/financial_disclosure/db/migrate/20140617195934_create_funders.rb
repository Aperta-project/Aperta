class CreateFunders < ActiveRecord::Migration
  def change
    create_table :funders do |t|
      t.string :name
      t.string :grant_number
      t.string :website
      t.boolean :funder_had_influence
      t.text :funder_influence_description
      t.references :task, index: true
      t.timestamps
    end

    create_table :funded_authors do |t|
      t.references :author, index: true
      t.references :funder, index: true
    end
  end
end
