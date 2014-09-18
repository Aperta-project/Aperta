class ExtractAwesomeAuthor < ActiveRecord::Migration
  def change

    add_column :authors, :actable_id, :integer
    add_column :authors, :actable_type, :string

    # this could have also been written as:
    # change_table :products do |t|
    #   t.actable
    # end

    create_table :awesome_authors do |t|
      t.string  :awesome_name
      t.integer :awesome_authors_task_id
    end
  end
end
