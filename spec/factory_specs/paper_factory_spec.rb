require 'rails_helper'

# Specs to ensure that PaperFactory generates models that contain all the
# necessary setup.

describe 'PaperFactory' do
  describe 'submitted_lite trait' do
    let(:time_freeze) { 1.day.ago }
    # fields to ignore when considering paper "equality"
    let(:ignore) { ['id', 'doi', 'paper_id'] }
    let(:title) { Faker::Lorem.words 10 }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper_submitted_lite) do
      Timecop.freeze(time_freeze) do
        # Persisting to the db changes the precision of the timestamps. Reload
        # to ensure that they are comparable.
        FactoryGirl.create(:paper, :submitted_lite,
                           title: title,
                           journal: journal,
                           submitting_user: creator).reload
      end
    end
    let(:reference_paper) do
      Timecop.freeze(time_freeze) do
        FactoryGirl.create(:paper, title: title, journal: journal)
      end
    end
    let(:creator) { FactoryGirl.create(:user) }

    before do
      Timecop.freeze(time_freeze) do
        reference_paper.submit! creator
        reference_paper.reload
      end
    end

    it 'should be equal' do
      expect(paper_submitted_lite).to mostly_eq(reference_paper).except(*ignore)
    end

    it 'should have equal decisions' do
      expect(paper_submitted_lite.decisions)
        .to mostly_eq_ar(reference_paper.decisions).except(*ignore)
    end

    it 'should have equal versioned_texts' do
      expect(paper_submitted_lite.versioned_texts)
        .to mostly_eq_ar(reference_paper.versioned_texts).except(*ignore)
    end
  end

  describe "ready_for_export trait" do
    subject(:paper) { create :paper, :ready_for_export }

    it "creates a paper ready for export" do
      expect(paper).to be
      expect(paper.publishing_state).to eq "accepted"
    end
  end
end
