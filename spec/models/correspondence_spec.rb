require 'rails_helper'

describe Correspondence, type: :model do
  context 'when external' do
    subject { FactoryGirl.build(:correspondence, :as_external) }

    it "validates presence of description" do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it "validates presence of sender" do
      subject.sender = nil
      expect(subject).to_not be_valid
    end

    it "validates presence of recipients" do
      subject.recipients = nil
      expect(subject).to_not be_valid
    end

    it "validates presence of body" do
      subject.body = nil
      expect(subject).to_not be_valid
    end
  end
end
