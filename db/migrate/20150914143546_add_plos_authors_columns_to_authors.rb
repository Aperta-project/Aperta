class AddPlosAuthorsColumnsToAuthors < ActiveRecord::Migration
  def change
    change_table :authors do |t|
      t.string :middle_initial
      t.string :email
      t.string :department
      t.string :title
      t.boolean :corresponding, default: false, null: false
      t.boolean :deceased, default: false, null: false
      t.string :affiliation
      t.string :secondary_affiliation
      t.string :contributions
      t.string :ringgold_id
      t.string :secondary_ringgold_id
    end
  end
end
