require 'rails_helper'

describe NestedQuestion do
  describe "validations" do
    subject(:nested_question) { FactoryGirl.build(:nested_question) }

    it "is valid" do
      expect(nested_question.valid?).to be true
    end

    it "requires ident" do
      nested_question.ident = nil
      expect(nested_question.valid?).to be false
    end

    it "doesn't require an owner_id" do
      nested_question.owner_id = nil
      expect(nested_question.valid?).to be true
    end

    it "requires an owner_type" do
      nested_question.owner_type = nil
      expect(nested_question.valid?).to be false
    end

    it "requires value_type" do
      nested_question.value_type = nil
      expect(nested_question.valid?).to be false
    end
  end

  describe "#attachment?" do
    it "returns true when value_type is for an attachment" do
      question = NestedQuestion.new(value_type: "attachment")
      expect(question.attachment?).to be true
    end
  end
end
