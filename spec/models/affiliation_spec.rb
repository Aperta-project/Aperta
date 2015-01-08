require 'rails_helper'

describe "Affiliation" do
  it "will be valid with default factory data" do
    affiliation = build(:affiliation)
    expect(affiliation).to be_valid
  end

  describe "email validation" do
    it "allows a valid email address" do
      affiliation = FactoryGirl.build(:affiliation, email: "someone@example.com")
      expect(affiliation).to be_valid
    end

    it "does not allow a invalid email address" do
      affiliation = FactoryGirl.build(:affiliation, email: "someonetypedsomethingbad")
      expect(affiliation).to_not be_valid
    end
  end

  context "by_date scope" do
    it "orders by start_date ascending" do
      fourth = create(:affiliation)
      first = create(:affiliation, start_date: 10.days.ago)
      third = create(:affiliation, start_date: Date.today)
      second = create(:affiliation, start_date: 3.days.ago)

      expect(Affiliation.by_date).to eq([first, second, third, fourth])
    end

    it "falls back to end_date if start_dates are the same" do
      third = create(:affiliation, start_date: 10.days.ago, end_date: 5.days.ago)
      second = create(:affiliation, start_date: 10.days.ago, end_date: 3.days.ago)
      first = create(:affiliation, start_date: 10.days.ago)

      expect(Affiliation.by_date).to eq([first, second, third])
    end
  end

  describe "date validations" do

    it "will not be valid if end date is not a valid date format" do
      affiliation = build(:affiliation, start_date: 3.days.ago, end_date: "not valid")
      expect(affiliation).to_not be_valid
    end

    it "will not be valid if start date is not a valid date format" do
      affiliation = build(:affiliation, start_date: "not valid", end_date: nil)
      expect(affiliation).to_not be_valid
    end

    it "will allow a nil start date and nil end date" do
      affiliation = build(:affiliation, start_date: nil, end_date: nil)
      expect(affiliation).to be_valid
    end

    it "requires start date if there is an end date" do
      affiliation = build(:affiliation, start_date: nil, end_date: 4.days.ago)
      expect(affiliation).to_not be_valid
    end

    it "will allow a start date without a end date" do
      affiliation = build(:affiliation, start_date: 3.days.ago, end_date: nil)
      expect(affiliation).to be_valid
    end

    it "will not allow a start date before end date" do
      affiliation = build(:affiliation, start_date: 3.days.ago, end_date: 4.days.ago)
      expect(affiliation).to_not be_valid
    end

  end
end
