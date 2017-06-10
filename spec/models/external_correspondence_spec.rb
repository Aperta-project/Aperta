require 'rails_helper'

describe ExternalCorrespondence, type: :model do
  let(:external_correspondence) { described_class.new }
  subject { external_correspondence }

  it { expect(described_class).to be < Correspondence }

  context 'validates' do
    it "#description is present" do
      subject { FactoryGirl.build(:external_correspondence, description: nil) }
      expect(subject).to_not be_valid
    end
    it "#sent_at is present" do
      subject { FactoryGirl.build(:external_correspondence, sent_at: nil) }
      expect(subject).to_not be_valid
    end
    it "#sender is present" do
      subject { FactoryGirl.build(:external_correspondence, sender: nil) }
      expect(subject).to_not be_valid
    end
    it "#recipients is present" do
      subject { FactoryGirl.build(:external_correspondence, recipients: nil) }
      expect(subject).to_not be_valid
    end
  end

  describe '#serialize_copied_recipients'
  describe '#unserialize_copied_recipients'
end
