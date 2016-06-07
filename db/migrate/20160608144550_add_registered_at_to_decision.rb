# Decisions may have the same version number,
# so we should use the registered-at date to sort them.
class AddRegisteredAtToDecision < ActiveRecord::Migration
  def change
    add_column :decisions, :registered_at, :datetime
    add_column :decisions, :major_version, :integer, null: true
    add_column :decisions, :minor_version, :integer, null: true
    remove_column :decisions, :registered, :boolean
    reversible do |direction|
      direction.up do
        remove_index :decisions, [:paper_id, :revision_number]
        execute <<-SQL
          UPDATE decisions
          SET major_version = revision_number,
              minor_version = 0,
              registered_at = created_at;
        SQL
      end

      direction.down do
        add_index :decisions, [:paper_id, :revision_number], unique: true
      end
    end
    remove_column :decisions, :revision_number, :integer
    remove_column :decisions, :rescind_minor_version, :integer
  end
end
