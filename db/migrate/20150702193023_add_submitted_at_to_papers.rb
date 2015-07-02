class AddSubmittedAtToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :submitted_at, :datetime
  end
end
