require 'spec_helper'

describe Declaration do
  it "defines a DEFAULT_DECLARATION_QUESTIONS" do
    expect(Declaration.const_defined? :DEFAULT_DECLARATION_QUESTIONS).to be_truthy
  end

  describe ".default_declarations" do
    before do
      stub_const "Declaration::DEFAULT_DECLARATION_QUESTIONS", [
        "What is your mother's maiden name?",
        "What was your favorite pet's name?",
        "What city did you grow up in?"
      ]
    end

    subject(:declarations) { Declaration.default_declarations }

    it "returns an array of declaration instances for each default question" do
      expect(declarations.size).to eq(3)
      expect(declarations[0].question).to eq "What is your mother's maiden name?"
      expect(declarations[0].answer).to be_nil
      expect(declarations[1].question).to eq "What was your favorite pet's name?"
      expect(declarations[1].answer).to be_nil
      expect(declarations[2].question).to eq "What city did you grow up in?"
      expect(declarations[2].answer).to be_nil
    end

    it "does not persist any of the declarations" do
      expect(declarations.all? &:new_record?).to be true
    end
  end
end
