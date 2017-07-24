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

      context 'revert concerns' do
        let(:answer) { FactoryGirl.build(:answer, card_content: card_content) }
        let!(:card_content) { FactoryGirl.create(:card_content) }
        let!(:check_box_answer) { FactoryGirl.create(:answer, card_content: check_box_card_content, owner: answer.owner, value: true) }
        let!(:check_box_card_content) {
          FactoryGirl.create(:card_content, content_type: 'check-box',
                                            value_type: 'boolean')
        }
        let!(:visible_with_value_card_content) {
          FactoryGirl.create(:card_content, content_type: 'display-with-value',
                                            visible_with_parent_answer: 'true',
                                            revert_children_on_hide: true,
                                            value_type: nil)
        }

        it 'keeps answer if revert_children_on_hide is true but answer is not hidden' do
          expected_value = 'nope'
          card_content.update!(default_answer_value: 'should not appear')
          visible_with_value_card_content.move_to_child_of(check_box_card_content)
          card_content.move_to_child_of(visible_with_value_card_content)
          visible_with_value_card_content.update!(visible_with_parent_answer: 'true')
          answer.update!(value: expected_value)
          expect(answer.reload.value).to eq expected_value
        end

        it 'reverts associated answer value if revert_children_on_hide is true' do
          answer.save!
          expected_value = 'nope'
          visible_with_value_card_content.move_to_child_of(check_box_card_content)
          card_content.move_to_child_of(visible_with_value_card_content)
          answer.update!(value: expected_value)
          expect(answer.value).to eq expected_value
        end
      end
    end

    context '#to_xml' do
      let!(:card_content) { FactoryGirl.build(:card_content, :with_string_match_validation, ident: 'thing') }
      let(:card) { FactoryGirl.build(:card) }
      let(:expected_xml) do
        <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <content ident="#{card_content.ident}" value-type="text" ident="thing">
          <validation validation-type="string-match">
            <error-message>oh noes!</error-message>
            <validator>/text/</validator>
          </validation>
        </content>
        XML
      end
      it 'generates the expected xml' do
        xml = card_content.to_xml
        expect(xml.to_s.strip).to match expected_xml.strip
      end
    end
  end

  context "root scope" do
    let!(:root_content) { FactoryGirl.create(:card_content, :root) }

    it 'returns all roots' do
      expect(CardContent.all.root.id).to be(root_content.id)
    end
  end

  context "properly ignored soft-deleted records" do
    let(:root_content) { FactoryGirl.create(:card_content, :root, :with_child) }

    it 'returns self and all child content' do
      expect(root_content.children.length).to eq(1)
      expect(root_content.self_and_descendants.length).to eq(2)
    end

    context "with deleted child content" do
      before do
        root_content.children.each(&:destroy)
        root_content.reload
      end

      it 'has no children' do
        expect(root_content.children.length).to eq(0)
        expect(root_content.self_and_descendants.length).to eq(1)
      end
    end
  end
end
