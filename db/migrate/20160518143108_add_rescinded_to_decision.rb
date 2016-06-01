# Decisions can be wrong, can be appealed, and when this happens we
# rescind them. That adds a minor version to the paper. These columns
# model the rescinded state of decisions.
class AddRescindedToDecision < ActiveRecord::Migration
  def change
    add_column :decisions, :rescinded, :boolean, default: false
    add_column :decisions, :rescind_minor_version, :integer
  end
end
