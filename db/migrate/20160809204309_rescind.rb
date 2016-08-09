# Prepare our data model for rescinded decisions
class Rescind < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def change
    change_column_null :versioned_texts, :major_version, true
    change_column_null :versioned_texts, :minor_version, true

    add_column :decisions, :registered_at, :datetime
    add_column :decisions, :minor_version, :integer, null: true
    add_column :decisions, :major_version, :integer, null: true

    reversible do |direction|
      direction.up do
        execute <<-SQL
          UPDATE decisions
          SET major_version = revision_number,
              minor_version = 0,
              registered_at = created_at;
        SQL
      end

      direction.down do
        execute <<-SQL
          UPDATE decisions
          SET revision_number = major_version;
        SQL
      end
    end

    remove_index :decisions, column: [:paper_id, :revision_number], unique: true
    remove_column :decisions, :revision_number, :integer

    add_column :decisions, :initial, :boolean, default: false, null: false
    add_column :decisions, :rescinded, :boolean, default: false

    add_index(
      :decisions,
      [:minor_version, :major_version, :paper_id],
      name: 'unique_decision_version',
      unique: true)
  end
end
