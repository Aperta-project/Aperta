class AddJournalIdToPapers < ActiveRecord::Migration
  def change
    add_reference :papers, :journal, index: true

    reversible do |dir|
      dir.up do
        # NB: This migration previously did something very wrong. It inserted
        # data into the db. Now it does nothing, which is better.
      end

      dir.down do
      end
    end
  end
end
