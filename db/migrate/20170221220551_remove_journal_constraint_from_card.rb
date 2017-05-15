##
# Currently, the only time that a Card to Journal relationship needs to be
# enforced is when a Card is created.  There are very few cases where it
# matters that a Card has a Journal and enforcing it at the model or db level
# complicates the object graph that needs to happen for tests and ci.
#
class RemoveJournalConstraintFromCard < ActiveRecord::Migration
  def change
    remove_foreign_key :cards, column: :journal_id
  end
end
