class CreateScratches < ActiveRecord::Migration
  def change
    create_table :scratches do |t|
      t.string :contents
      t.timestamps null: false
    end
  end
end
