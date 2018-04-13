# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Prepare our data model for rescinded decisions
class Rescind < ActiveRecord::Migration
  # We need to manually reset the columns because our local class definitions
  # interfere somehow with the migrations column resetting.
  def reset_columns
    say("Manually resetting column information")
    [::Decision, ::VersionedText, ::Paper].each do |m|
      m.reset_column_information
    end
  end

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
      (major_version, minor_version) =
        paper.decidable_versions.fetch(revision_number)
      update!(
        major_version: major_version,
        minor_version: minor_version,
        registered_at: created_at)
      # Sanity check: every decision should have a versioned text that it
      # corresponds to
      fail "Trying to set the version on decision #{id} to #{major_version}, \
#{minor_version}, but there is no VersionedText with that version" \
        unless paper.versioned_texts.where(
          major_version: major_version,
          minor_version: minor_version
        ).count == 1
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

    # Generate a list of versions (as [major, minor]) that should have decisions
    # corresponding to them
    def decidable_versions
      retval = []
      retval << [0, 0] if gradual_engagement
      retval += versioned_texts.pluck(:major_version, :minor_version)
        .group_by { |p| p[0] }
        .map { |_, v| v.sort_by { |p| p[1] }.last } - [0, 0]
      retval.uniq # remove dup [0,0] entries
    end

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
    reversible do |direction|
      direction.down do
        reset_columns
      end
    end

    change_column_null :versioned_texts, :major_version, true
    change_column_null :versioned_texts, :minor_version, true

    add_column :decisions, :registered_at, :datetime
    add_column :decisions, :minor_version, :integer, null: true
    add_column :decisions, :major_version, :integer, null: true

    reversible do |direction|
      direction.up do
        say_with_time("Initializing some Decisions as drafts") do
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
          Decision.count # returned for logging
        end

        say_with_time("Initializing some VersionedTexts as drafts") do
          count = 0
          VersionedText.find_each do |versioned_text|
            paper = versioned_text.paper
            next if paper.blank?
            if versioned_text.latest_on_paper? && paper.draft_state?
              versioned_text.be_draft!
              count += 1
            end
          end
          count # returned for logging
        end
      end

      direction.down do
        say_with_time("Removing draft status from Decisions") do
          Decision.find_each do |decision|
            if decision.major_version.present?
              decision.update! revision_number: decision.major_version
            else
              last_decision_index = decision.paper.decisions.count - 1
              decision.update!(revision_number: last_decision_index)
            end
          end
          Decision.count # returned for logging
        end

        say_with_time("Removing draft status from VersionedTexts") do
          draft_texts = VersionedText.where(major_version: nil)
          count = draft_texts.count
          draft_texts.find_each do |versioned_text|
            if versioned_text.paper.minor_version_state?
              versioned_text.be_minor_version!
            else
              versioned_text.be_major_version!
            end
          end
          count # returned for logging
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

    reversible do |direction|
      direction.up do
        reset_columns
      end
    end
  end
end
