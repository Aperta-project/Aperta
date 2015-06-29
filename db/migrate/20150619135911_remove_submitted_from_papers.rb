class RemoveSubmittedFromPapers < ActiveRecord::Migration
  def up
    execute "UPDATE papers SET publishing_state = 'unsubmitted'"
    execute "UPDATE papers SET publishing_state = 'submitted' WHERE submitted = 'true'"
    execute "UPDATE papers SET publishing_state = 'published' WHERE published_at IS NOT null"

    remove_column :papers, :submitted
  end

  def down
    add_column :papers, :submitted, :boolean, default: false, null: false
    execute "UPDATE papers SET submitted = 'true' WHERE publishing_state <> 'unsubmitted'"
  end
end
