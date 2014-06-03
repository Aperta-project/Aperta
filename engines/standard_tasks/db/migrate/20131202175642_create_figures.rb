class CreateFigures < ActiveRecord::Migration
  def change
    create_table :figures do |t|
      t.string :attachment
      t.belongs_to :paper, index: true

      t.timestamps
    end
  end
end
