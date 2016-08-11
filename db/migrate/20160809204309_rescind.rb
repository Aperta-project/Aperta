# Prepare our data model for rescinded decisions
class Rescind < ActiveRecord::Migration
  # Redundantly define class for future-proofing
  class Decision < ActiveRecord::Base
    belongs_to :paper

    def latest_on_paper?
      self == paper.decisions.reorder('created_at asc').last
    end

    def make_draft!
      update!(
        major_version: nil,
        minor_version: nil,
        registered_at: nil)
    end

    def make_complete!
      update!(
        major_version: revision_number,
        minor_version: 0,
        registered_at: created_at)
    end
  end

  # Redundantly define class for future-proofing
  class Paper < ActiveRecord::Base
    has_many :decisions

    # States that come before a final decision has been made
    def non_terminal_publishing_state?
      !['accepted', 'rejected', 'published'].member?(publishing_state)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def change
    change_column_null :versioned_texts, :major_version, true
    change_column_null :versioned_texts, :minor_version, true

    add_column :decisions, :registered_at, :datetime
    add_column :decisions, :minor_version, :integer, null: true
    add_column :decisions, :major_version, :integer, null: true

    reversible do |direction|
      direction.up do
        Decision.find_each do |decision|
          if decision.latest_on_paper?
            if decision.verdict
              if decision.paper.non_terminal_publishing_state?
                # paper isn't in a terminal publishing state. These are
                # assumed to be decisions that are in the process of being
                # authored (the editor has selected a decision but hasn't
                # clicked the register button yet).
                decision.make_draft!
              else
                # assume last decision is complete if the paper is in a
                # terminal publishing state and the decision has a verdict
                decision.make_complete!
              end
            else
              # decision has no verdict, so it can't be complete
              decision.make_draft!
            end
          else
            # decision is not latest on paper, so it must be complete
            decision.make_complete!
          end
        end
      end

      direction.down do
        Decision.find_each do |decision|
          if decision.major_version.present?
            decision.update! revision_number: decision.major_version
          else
            last_decision_index = decision.paper.decisions.count - 1
            decision.update!(revision_number: last_decision_index)
          end
        end
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
