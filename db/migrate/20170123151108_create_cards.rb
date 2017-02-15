# Create initial version of Card model
class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.timestamps null: false
    end
  end
end
