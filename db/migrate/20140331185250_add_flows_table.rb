class AddFlowsTable < ActiveRecord::Migration
  def change
    create_table :flows do |t|
      t.timestamps
      t.string :title
      t.string :empty_text
    end
  end
end
