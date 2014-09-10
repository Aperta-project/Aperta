class ExtractAwesomeAuthor < ActiveRecord::Migration
  def change
    remove_column :authors, :department, :string
    remove_column :authors, :title, :string
    remove_column :authors, :corresponding, :boolean, default: false
    remove_column :authors, :deceased, :boolean, default: false
    remove_column :authors, :affiliation, :string
    remove_column :authors, :secondary_affiliation, :string

    add_column :authors, :custom_author_id, :integer
    add_column :authors, :custom_author_type, :string

    create_table :awesome_authors do |t|
      t.string :awesome_name, default: "aaron"
      t.string :department
      t.string :title
      t.boolean :deceased, default: false
      t.string :affiliation
      t.string :secondary_affiliation
    end
  end
end
