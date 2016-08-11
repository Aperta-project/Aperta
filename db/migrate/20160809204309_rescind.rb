# Prepare our data model for rescinded decisions
class Rescind < ActiveRecord::Migration
  # Redundantly define class for future-proofing
  class Decision < ActiveRecord::Base
    belongs_to :paper

    def latest_on_paper?
      self == paper.decisions.reorder('created_at asc').last
    end

    def be_draft!
      update!(
        major_version: nil,
        minor_version: nil,
        registered_at: nil)
    end

    def be_complete!
      update!(
        major_version: revision_number,
        minor_version: 0,
        registered_at: created_at)
    end
  end

  # Redundantly define class for future-proofing
  class VersionedText < ActiveRecord::Base
    belongs_to :paper

    def latest_on_paper?
      self == paper.versioned_texts
        .reorder('major_version asc, minor_version asc').last
    end

    def be_draft!
      update! major_version: nil, minor_version: nil
    end

    # Give the text a new MAJOR version.
    def be_major_version!
      update!(
        major_version: (paper.major_version || -1) + 1,
        minor_version: 0)
    end

    # Give the text a new MINOR version
    def be_minor_version!
      update!(
        major_version: (paper.major_version || 0),
        minor_version: (paper.minor_version || -1) + 1)
    end
  end

  # Redundantly define class for future-proofing
  class Paper < ActiveRecord::Base
    has_many :decisions
    has_many :versioned_texts

    # States that come before a final decision has been made
    def non_terminal_publishing_state?
      !['accepted', 'rejected', 'published'].member?(publishing_state)
    end

    def draft_state?
      draft_states = [
        'unsubmitted',
        'invited_for_full_submission',
        'checking',
        'in_revision']
      draft_states.member?(publishing_state)
    end

    def minor_version_state?
      ["checking", "invited_for_full_submission"].member?(publishing_state)
    end

    def major_version
      versioned_texts.maximum(:major_version)
    end

    def minor_version
      versioned_texts.maximum(:minor_version)
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
                decision.be_draft!
              else
                # assume last decision is complete if the paper is in a
                # terminal publishing state and the decision has a verdict
                decision.be_complete!
              end
            else
              # decision has no verdict, so it can't be complete
              decision.be_draft!
            end
          else
            # decision is not latest on paper, so it must be complete
            decision.be_complete!
          end
        end

        VersionedText.find_each do |versioned_text|
          paper = versioned_text.paper
          if versioned_text.latest_on_paper? && paper.draft_state?
            versioned_text.be_draft!
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

        VersionedText.where(major_version: nil).find_each do |versioned_text|
          if paper.minor_version_state?
            versioned_text.be_minor_version!
          else
            versioned_text.be_major_version!
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
