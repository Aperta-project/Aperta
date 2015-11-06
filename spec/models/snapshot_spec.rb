require 'rails_helper'

describe Snapshot, type: :model do
  subject(:snapshot){ FactoryGirl.build(:snapshot) }

  describe "validations" do
    it "is valid" do
      expect(snapshot.valid?).to be(true)
    end

    it "requires a :paper" do
      snapshot.paper = nil
      expect(snapshot.valid?).to be(false)
    end

    it "requires a :source" do
      snapshot.source = nil
      expect(snapshot.valid?).to be(false)
    end

    it "requires a :major_version" do
      snapshot.major_version = nil
      expect(snapshot.valid?).to be(false)
    end

    it "requires a :minor_version" do
      snapshot.minor_version = nil
      expect(snapshot.valid?).to be(false)
    end
  end

end
