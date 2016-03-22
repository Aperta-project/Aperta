# Group authors are in teh authors ist, but they're not a single
# person, so they store very different data.
class CreateGroupAuthor < ActiveRecord::Migration
  def change
    create_table :group_authors do |t|
      t.references :paper
      t.string :contact_first_name
      t.string :contact_middle_name
      t.string :contact_last_name
      t.string :contact_email
      t.string :name
      t.string :initial

      t.timestamps
    end
  end
end
