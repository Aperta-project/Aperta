# This migration comes from plos_authors (originally 20141015204939)
class CreatePlosAuthor < ActiveRecord::Migration
  def change
    create_table :plos_authors_plos_authors do |t|
      t.references :plos_authors_task
      t.string   :middle_initial
      t.string   :email
      t.string   :department
      t.string   :title
      t.boolean  :corresponding,         default: false, null: false
      t.boolean  :deceased,              default: false, null: false
      t.string   :affiliation
      t.string   :secondary_affiliation
      t.timestamps
    end

    change_table :authors do |t|
      t.string :actable_type
      t.integer :actable_id
    end

    remove_column :authors, :middle_initial, :string
    remove_column :authors, :email, :string
    remove_column :authors, :department, :string
    remove_column :authors, :title, :string
    remove_column :authors, :corresponding, :boolean, default: false, null: false
    remove_column :authors, :deceased,  :boolean, default: false, null: false
    remove_column :authors, :affiliation, :string
    remove_column :authors, :secondary_affiliation, :string
  end
end
