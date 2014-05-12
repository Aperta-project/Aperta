class CreateManuscripts < ActiveRecord::Migration
  def change
    create_table :manuscripts do |t|
      t.string :source
      t.references :paper
      t.timestamps
    end
  end
end
