class CreatePlosEditorialManagers < ActiveRecord::Migration
  def change
    create_table :plos_editorial_managers do |t|

      t.timestamps null: false
    end
  end
end
