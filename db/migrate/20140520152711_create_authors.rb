class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_initial
      t.string :email
      t.string :department
      t.string :title
      t.boolean :corresponding, default: false, null: false
      t.boolean :deceased, default: false, null: false

      t.timestamps
    end
  end
end
