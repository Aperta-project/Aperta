require 'rails_helper'
require 'models/concerns/versioned_thing_shared_examples'

describe Decision do
  let(:paper) { FactoryGirl.build :paper, :submitted_lite }
  subject(:decision) do
    FactoryGirl.build(
      :decision,
      paper: paper,
      major_version: nil,
      minor_version: nil)
  end

  it_behaves_like 'a thing with major and minor versions', :decision

  it "the first decision always starts with a nil version number" do
    expect(decision.major_version).to eq(nil)
  end

  describe '#revision?' do
    it 'counts major_revision as a revision' do
      decision.update_attribute(:verdict, 'major_revision')
      expect(decision.revision?).to be true
    end

    it 'counts minor_revision as a revision' do
      decision.update_attribute(:verdict, 'minor_revision')
      expect(decision.revision?).to be true
    end
  end

  describe '#rescind!' do
    it 'flags rescinded as true' do
      allow(paper).to receive(:rescind!)
      expect { decision.rescind! }.to change { decision.rescinded }.to be(true)
    end

    it 'calls paper.rescind!' do
      expect(paper).to receive(:rescind!)
      decision.rescind!
    end
  end

  describe '#latest?' do
    let(:paper) { FactoryGirl.create :paper, :submitted_lite }

    it 'returns true if it is the latest decision' do
      paper.decisions.destroy_all
      early_decision = paper.decisions.create!(registered_at: DateTime.now.utc, minor_version: 0, major_version: 0)
      latest_decision = paper.decisions.create!
      expect(early_decision.latest?).to be false
      expect(latest_decision.latest?).to be true
    end
  end

  describe '#verdict_valid?' do
    context 'when the verdict is valid' do
      it 'validates for major_revision' do
        decision.update_attribute(:verdict, 'major_revision')
        expect(decision.valid?).to be true
      end

      it 'validates for minor_revision' do
        decision.update_attribute(:verdict, 'minor_revision')
        expect(decision.valid?).to be true
      end

      it 'validates for accept' do
        decision.update_attribute(:verdict, 'accept')
        expect(decision.valid?).to be true
      end

      it 'validates for reject' do
        decision.update_attribute(:verdict, 'reject')
        expect(decision.valid?).to be true
      end
    end

    context 'when the verdict is invalid' do
      it 'fails validation for an unknown verdict' do
        decision.update_attribute(:verdict, 'Woop de doo')
        expect(decision.valid?).to be false
      end
    end
  end

  describe 'terminal?' do
    it "is true for an accept decision" do
      decision.verdict = "accept"
      expect(decision.terminal?).to be(true)
    end

    it "is true for a reject decision" do
      decision.verdict = "reject"
      expect(decision.terminal?).to be(true)
    end

    it "is false for a revise decision" do
      decision.verdict = "revise"
      expect(decision.terminal?).to be(false)
    end
  end

  describe 'rescindable?' do
    context 'when the decision is not registered' do
      it 'is not rescindable' do
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision has been rescinded' do
      before do
        allow(decision).to receive(:rescinded).and_return(true)
      end

      it 'is not rescindable' do
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision is not the latest decision' do
      before do
        allow(decision).to receive(:latest_registered?).and_return(false)
      end

      it 'is not rescindable' do
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision is the latest, has a verdict, but the paper has moved on in the process' do
      before do
        allow(decision).to receive(:paper_in_expected_state_given_verdict?).and_return(false)
      end

      it 'is not rescindable' do
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision is the latest, has a verdict, and the paper is in the right state' do
      before do
        allow(decision).to receive(:paper_in_expected_state_given_verdict?).and_return(true)
        allow(decision).to receive(:latest_registered?).and_return(true)
      end

      it 'is rescindable' do
        expect(decision.rescindable?).to be(true)
      end
    end
  end

  describe 'PUBLISHING_STATE_BY_VERDICT' do
    it 'contains an entry for every verdict' do
      expect(Decision::PUBLISHING_STATE_BY_VERDICT.keys).to contain_exactly(*Decision::VERDICTS)
    end

    it 'has values which are all publishing states' do
      expect(Paper::STATES.map(&:to_s)).to include(*Decision::PUBLISHING_STATE_BY_VERDICT.values)
    end
  end

  describe 'updating the author_response' do
    context 'when the decision is not the latest registered_decision' do
      before do
        allow(decision).to receive(:latest_registered?).and_return(false)
        allow(decision).to receive(:persisted?).and_return(true)
      end

      it 'does not validate' do
        decision.update(author_response: Faker::Lorem.paragraph(2))
        expect(decision.valid?).to be(false)
      end
    end

    context 'when the decision is the latest registered_decision' do
      before do
        allow(decision).to receive(:latest_registered?).and_return(true)
      end

      it 'validates' do
        decision.update(author_response: Faker::Lorem.paragraph(2))
        expect(decision.valid?).to be(true)
      end
    end
  end

  describe 'updating the letter or verdict' do
    before do
      allow(decision).to receive(:persisted?).and_return(true)
    end

    context 'when the decision is not a draft' do
      before do
        allow(decision).to receive(:draft?).and_return(false)
      end

      it 'does not validate when updating the letter' do
        decision.update(letter: Faker::Lorem.paragraph(2))
        expect(decision.valid?).to be(false)
      end

      it 'does not validate when updating the verdict' do
        decision.update(verdict: 'accept')
        expect(decision.valid?).to be(false)
      end
    end

    context 'when the decision is a draft' do
      before do
        allow(decision).to receive(:draft?).and_return(true)
      end

      it 'validates when updating the letter' do
        decision.update(letter: Faker::Lorem.paragraph(2))
        expect(decision.valid?).to be(true)
      end

      it 'validates when updating the verdict' do
        decision.update(verdict: 'accept')
        expect(decision.valid?).to be(true)
      end
    end
  end
end
