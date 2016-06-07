require 'rails_helper'

describe Decision do
  let!(:decision) do
    paper = FactoryGirl.create :paper
    paper.decisions.first
  end
  let(:paper) { decision.paper }

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
    before do
      paper.update_columns(publishing_state: :rejected)
    end

    it 'flags rescinded as true' do
      expect { decision.rescind! }.to change { decision.rescinded }.to be(true)
    end

    it 'calls paper.rescind!' do
      expect(paper).to receive(:rescind!)
      decision.rescind!
    end
  end

  describe '#latest?' do
    it 'returns true if it is the latest decision' do
      paper.decisions.destroy_all
      early_decision = paper.decisions.create! registered_at: DateTime.now.utc
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

    it "is true for a revise decision" do
      decision.verdict = "revise"
      expect(decision.terminal?).to be(false)
    end
  end

  describe 'rescindable?' do
    context 'when the decision is not registered' do
      it 'is not rescindable' do
        decision.registered_at = nil
        decision.save!
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision has been rescinded' do
      it 'is not rescindable' do
        decision.registered_at = DateTime.now.utc
        decision.rescinded = true
        decision.save!
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision has a verdict but is not the latest decision' do
      it 'is not rescindable' do
        paper.publishing_state = "in_revision"
        decision.verdict = "major_revision"
        decision.registered_at = DateTime.now.utc
        decision.save!
        paper.decisions.create!(registered_at: DateTime.now.utc)
        paper.save!
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision is the latest, has a verdict, but the paper has moved on in the process' do
      it 'is not rescindable' do
        decision.registered_at = DateTime.now.utc
        paper.publishing_state = "submitted"
        decision.verdict = "accept"
        decision.save!
        paper.save!
        expect(decision.rescindable?).to be(false)
      end
    end

    context 'when the decision is the latest, has a verdict, and the paper is in the right state' do
      it 'is rescindable' do
        decision.registered_at = DateTime.now.utc
        paper.publishing_state = "accepted"
        decision.verdict = "accept"
        decision.save!
        paper.save!
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
end
