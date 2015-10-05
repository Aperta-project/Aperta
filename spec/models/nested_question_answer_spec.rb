require 'rails_helper'

describe NestedQuestionAnswer do
  subject(:nested_question_answer) { FactoryGirl.build(:nested_question_answer) }

  describe "validations" do
    it "is valid" do
      expect(nested_question_answer.valid?).to be true
    end

    it "requires value_type" do
      nested_question_answer.value_type = nil
      expect(nested_question_answer.valid?).to be false
    end

    context "and the value_type is boolean" do
      before { nested_question_answer.value_type = "boolean" }

      it "is valid when the value not a truthy value" do
        nested_question_answer.value = false
        expect(nested_question_answer.valid?).to be true
      end
    end

    context "and the value_type is attachment" do
      before { nested_question_answer.value_type = "attachment" }

      it "is valid with a value" do
        nested_question_answer.value = "http://someimagepath.png"
        expect(nested_question_answer.valid?).to be true
      end

      it "is not valid without a value" do
        nested_question_answer.value = nil
        expect(nested_question_answer.valid?).to be false
      end
    end
  end

  describe "#value_type" do
    context "valid values" do
      it "can set to attachment" do
        nested_question_answer.value_type = "attachment"
        expect(nested_question_answer.value_type).to eq "attachment"
      end

      it "can set to text" do
        nested_question_answer.value_type = "text"
        expect(nested_question_answer.value_type).to eq "text"
      end

      it "can set to boolean" do
        nested_question_answer.value_type = "boolean"
        expect(nested_question_answer.value_type).to eq "boolean"
      end

      it "can set to question-set" do
        nested_question_answer.value_type = "question-set"
        expect(nested_question_answer.value_type).to eq "question-set"
      end
    end
  end

  describe "#value" do
    context "and the value_type is attachment" do
      before { nested_question_answer.value_type = "attachment" }

      it "returns the stored value" do
        nested_question_answer.value = "MyFile.png"
        expect(nested_question_answer.value).to eq "MyFile.png"
      end
    end

    context "and the value_type is text" do
      before { nested_question_answer.value_type = "text" }

      it "returns the stored value as a string" do
        nested_question_answer.value = "Hello there."
        expect(nested_question_answer.value).to eq "Hello there."
      end
    end

    context "and the value_type is question-set" do
      before { nested_question_answer.value_type = "question-set" }

      it "returns the stored value as a string" do
        nested_question_answer.value = "Hello there."
        expect(nested_question_answer.value).to eq "Hello there."
      end
    end

    context "and the value_type is boolean" do
      before { nested_question_answer.value_type = "boolean" }

      %w(t T true True TRUE y Y yes YES 1).each do |truthy_value|
        it "returns true when the value is #{truthy_value}" do
          nested_question_answer.value = truthy_value
          expect(nested_question_answer.value).to be true
        end
      end

      it "returns false otherwise" do
        %w(false f 0 other-value goes here).each do |falsy_value|
          nested_question_answer.value = falsy_value
          expect(nested_question_answer.value).to be false
        end
        nested_question_answer.value = "some other value"
        expect(nested_question_answer.value).to be false
      end
    end

    context "and the value_type is not supported" do
      before { nested_question_answer.value_type = "unsupported-value-type" }

      it "returns nil" do
        expect(nested_question_answer.value).to be nil
      end
    end
  end
end
