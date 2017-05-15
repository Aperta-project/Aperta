require 'rails_helper'

describe CardContent do
  subject(:card_content) { FactoryGirl.build(:card_content) }

  context 'validation' do
    it 'is valid' do
      expect(card_content).to be_valid
    end

    context "default_answer_value" do
      it "cannot be present when value_type is blank" do
        card_content.value_type = nil
        card_content.default_answer_value = "foo"
        expect(card_content).to_not be_valid
        expect(card_content.error_on(:default_answer_value)).to include(/value type must be present/i)
      end

      context "with possible values" do
        subject(:card_content) do
          FactoryGirl.build(
            :card_content,
            content_type: "radio",
            value_type: "text",
            possible_values: [{ "label" => "Bar", "value" => "bar" },
                              { "label" => "Baz", "value" => "baz" }]
          )
        end
        it "must be one of the possible_values if they are present" do
          card_content.default_answer_value = "foo"
          expect(card_content).to_not be_valid
          expect(card_content.error_on(:default_answer_value)).to include(/must be one of the following values/i)
        end
        it "is valid if it matches one of the possible_values' value" do
          card_content.default_answer_value = "baz"
          expect(card_content).to be_valid
        end
      end
    end
  end

  context "root scope" do
    let!(:root_content) { FactoryGirl.create(:card_content, parent: nil) }

    it 'returns all roots' do
      expect(CardContent.all.root.id).to be(root_content.id)
    end
  end
end
