class Author < ActiveRecord::Base
  has_one :author_list_item
end

class AuthorListItem < ActiveRecord::Base
end

class AddAuthorListItem < ActiveRecord::Migration
  def up
    create_table :author_list_items do |t|
      t.integer :position
      t.references :author, null: false, polymorphic: true
      t.references :task, null: false, polymorphic: true
      t.timestamps
    end

    Author.all().each do |author|
      AuthorListItem.create!(
        author_id: author.id,
        author_type: "Author",
        position: author.position,
        task_id: author.authors_task.id,
        task_type: "TahiStandardTasks::AuthorsTask"
      )
    end

    remove_column :authors, :authors_task_id
    remove_column :authors, :position
  end

  def down
    add_column :authors, :authors_task_id, :integer
    add_column :authors, :position, :integer

    Author.all().each do |author|
      author.update(
        authors_task_id: author.author_list_item.task_id,
        position: author.author_list_item.position
      )
    end

    drop_table :author_list_items
  end
end
