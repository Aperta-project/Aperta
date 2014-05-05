require 'spec_helper'

describe "Affiliation" do
  it "will be valid with default factory data" do
    affiliation = FactoryGirl.build(:affiliation)
    expect(affiliation).to be_valid
  end

  context "by_date scope" do
    it "orders by start_date ascending" do
      fourth = FactoryGirl.create(:affiliation)
      first = FactoryGirl.create(:affiliation, start_date: 10.days.ago)
      third = FactoryGirl.create(:affiliation, start_date: Date.today)
      second = FactoryGirl.create(:affiliation, start_date: 3.days.ago)

      expect(Affiliation.by_date).to eq([first, second, third, fourth])
    end

    it "falls back to end_date if start_dates are the same" do
      third = FactoryGirl.create(:affiliation, start_date: 10.days.ago, end_date: 5.days.ago)
      second = FactoryGirl.create(:affiliation, start_date: 10.days.ago, end_date: 3.days.ago)
      first = FactoryGirl.create(:affiliation, start_date: 10.days.ago)

      expect(Affiliation.by_date).to eq([first, second, third])
    end
  end
end
