class ExtractAwesomeAuthor < ActiveRecord::Migration
  def change
    add_column :authors, :actable_id, :integer
    add_column :authors, :actable_type, :string

    create_table :awesome_authors do |t|
      t.string :awesome_name
      t.integer :awesome_task_id
    end
  end
end
