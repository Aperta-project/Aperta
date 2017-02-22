class AddJournalIdToCards < ActiveRecord::Migration
  def change
    add_reference :cards, :journal, index: true, foreign_key: true
  end
end
