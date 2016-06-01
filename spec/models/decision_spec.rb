require 'rails_helper'

describe Decision do
  let!(:decision) do
    paper = FactoryGirl.create :paper
    paper.decisions.first
  end
  let(:paper) { decision.paper }

  it "the first decision always has 0 revision number" do
    expect(decision.revision_number).to eq(0)
  end

  it "automatically increments the revision number" do
    new_decision = paper.decisions.create!
    expect(new_decision.revision_number).to eq 1
  end

  it "automatically increments the revision number" do
    paper.decisions.create!
    newest_decision = paper.decisions.create!
    expect(newest_decision.revision_number).to eq 2
  end

  it "returns the correct revision number even if a revision number is provided while creating" do
    invalid_decision = paper.decisions.create! revision_number: 0
    expect(invalid_decision.revision_number).to eq 1
  end

  it "makes sure that the revision number is always unique" do
    invalid_decision = paper.decisions.create! # 1
    expect do
      invalid_decision.update_attribute :revision_number, 0
    end.to raise_error(ActiveRecord::RecordNotUnique)
    expect(invalid_decision.revision_number).to_not eq(1)
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

  describe '#latest?' do
    it 'returns true if it is the latest decision' do
      early_decision = paper.decisions.create!
      paper.decisions.create!
      latest_decision = paper.decisions.create!
      (FactoryGirl.create :paper).decisions.create!
      expect(early_decision.latest?).to be false
      expect(latest_decision.latest?).to be true
    end
  end

  describe ".completed" do
    context "with a verdict" do
      let(:decision) { FactoryGirl.create(:decision, :rejected) }

      it "is returned" do
        expect(Decision.completed).to eq([decision])
      end
    end

    context "without a verdict" do
      let(:decision) { FactoryGirl.create(:decision, :pending) }

      it "is not returned" do
        expect(Decision.completed).to be_empty
      end
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
end
