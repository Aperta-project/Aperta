class AddSubmittedAtToPapers < ActiveRecord::Migration
  def up
    add_column :papers, :submitted_at, :datetime

    execute "UPDATE papers SET submitted_at = created_at WHERE publishing_state <> 'unsubmitted'"
  end

  def down
    remove_column :papers, :submitted_at
  end
end
