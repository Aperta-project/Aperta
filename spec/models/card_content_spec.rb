require 'rails_helper'
# rubocop:disable Metrics/BlockLength
describe CardContent do
  subject(:card_content) { FactoryGirl.build(:card_content) }

  context 'validation' do
    it 'is valid' do
      expect(card_content).to be_valid
    end

    context 'combinations of content-type and value-type in VALUE_TYPES_FOR_CONTENT' do
      context 'the content type is listed' do
        it 'is valid when the value type is in the array for the content type' do
          expect(FactoryGirl.build(:card_content, content_type: 'dropdown', value_type: 'text')).to be_valid
        end

        it 'is invalid when the value type is in not the array for the content type' do
          expect(FactoryGirl.build(:card_content, content_type: 'dropdown', value_type: 'foo')).to_not be_valid
          expect(FactoryGirl.build(:card_content, content_type: 'dropdown', value_type: nil)).to_not be_valid
        end
      end
      context 'the content type is unlisted' do
        it 'is valid when the value type is nil' do
          expect(FactoryGirl.build(:card_content, content_type: 'display-children', value_type: nil)).to be_valid
        end
        it 'is invalid when the value type is present' do
          expect(FactoryGirl.build(:card_content, content_type: 'display-children', value_type: 'text')).to_not be_valid
        end
      end
    end
  end

  it "sets and retrieves boolean attributes" do
    value = false
    card_content.required_field = value
    expect(card_content.required_field).to eq(value)
  end

  it "sets and retrieves string attributes" do
    value = "test string"
    card_content.text = value
    expect(card_content.text).to eq(value)
  end

  it "sets and retrieves json attributes" do
    value = { 'a' => 1, 'b' => 2 }
    card_content.possible_values = value
    expect(card_content.possible_values).to eq(value)
  end

  context "default_answer_value" do
    it "cannot be present when value_type is blank" do
      card_content.value_type = nil
      card_content.default_answer_value = "foo"
      expect(card_content).to_not be_valid
      expect(card_content.error_on(:base)).to include(/value type must be present/i)
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
        expect(card_content.error_on(:base)).to include(/must be one of the following values/i)
      end
      it "is valid if it matches one of the possible_values' value" do
        card_content.default_answer_value = "baz"
        expect(card_content).to be_valid
      end
    end
  end

  context '#to_xml' do
    let!(:card_content) { FactoryGirl.create(:card_content, :with_string_match_validation, ident: 'thing') }
    let(:expected_xml) do
      <<-XML.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <content ident="#{card_content.ident}" value-type="text">
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

  context "#preload_descendants" do
    let(:content) { FactoryGirl.create(:card_content, :root, :with_children) }

    def do_nothing(card_content, acc = 0)
      acc += 1
      card_content.nil?
      card_content.children.each do |child|
        acc += do_nothing(child)
      end
      acc
    end

    before do
      # Inserting the data and loading
      content.card_content_validations
    end

    it 'uses three db queries' do
      expect { content.preload_descendants }.to make_database_queries(count: 3)
    end

    it 'does not make db queries when recursing' do
      content.preload_descendants

      expect { do_nothing(content) }.to_not make_database_queries
      # 1 root + 5 children + (0..4) children each = 16
      expect(do_nothing(content)).to eq(16)
    end

    context '#unsorted_child_ids' do
      it 'does not make db queries when recursing' do
        content.preload_descendants

        expect { content.unsorted_child_ids }.to_not make_database_queries
        expect(content.unsorted_child_ids).to contain_exactly(*content.children.map(&:id))
      end

      it 'works when #preload_descendants not called' do
        expect(content.unsorted_child_ids).to contain_exactly(*content.children.map(&:id))
      end

      context 'with a leaf node' do
        let(:content) { FactoryGirl.create(:card_content, :root) }

        it 'returns an empty array' do
          expect(content.unsorted_child_ids).to be_empty
        end
      end
    end
  end

  context '#children' do
    let(:content) { FactoryGirl.create(:card_content, :root, :with_child) }

    it 'works when preload_descendants is not called' do
      expect(content.children.count).to eq(1)
    end

    it 'works when preload_descendants is called' do
      content.preload_descendants
      expect(content.children.count).to eq(1)
    end

    it 'returns the same content' do
      without = content.children
      content.preload_descendants
      expect(content.children).to eq(without)
    end
  end

  context "root scope" do
    let!(:root_content) { FactoryGirl.create(:card_content, :root) }

    it 'returns all roots' do
      expect(CardContent.roots).to include(root_content)
    end
  end
end
