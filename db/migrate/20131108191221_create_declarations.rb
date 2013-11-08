class CreateDeclarations < ActiveRecord::Migration
  def change
    create_table :declarations do |t|
      t.text :question, null: false
      t.text :answer
      t.references :paper, index: true
    end
  end
end
