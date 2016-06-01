# We have no way, up to now, of determining if a decision has been
# registered and emailed to an author, or if the decision letter is
# still being drafted. These flags will let us do that, and tell if
# the decision is from the initial decision card.
class AddRegisteredToDecision < ActiveRecord::Migration
  def change
    add_column :decisions, :registered, :boolean, default: false, null: false
    add_column :decisions, :initial, :boolean, default: false, null: false
  end
end
