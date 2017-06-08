require 'rails_helper'

describe XmlCardLoader do
  let(:content1) { '<content ident="foo" content-type="text"><text>foo</text></content>' }
  let(:content2) { '<content ident="bar" content-type="text"><text>bar</text></content>' }

  let(:card) { FactoryGirl.create(:card, :versioned, name: "original name") }
  let(:xml_card_loader) { XmlCardLoader.new(card) }

  describe 'error handling' do
    context 'xml does not adhere to xml schema' do
      let(:xml) { '<foo/>' }

      it 'throws an exception' do
        expect { xml_card_loader.load(xml) }.to raise_exception(XmlCardDocument::XmlValidationError) { |ex| ex.errors.first[":message"] == 'element "foo" not allowed anywhere; expected element "card"' }
      end
    end

    context 'xml has two content roots' do
      let(:xml) { "<card name='Foo' required-for-submission='true' workflow-display-only='true'>#{content1}#{content2}</card>" }

      it 'throws an exception' do
        expect { xml_card_loader.load(xml) }.to raise_exception(XmlCardDocument::XmlValidationError) { |ex| ex.errors.first[":message"] == 'element "content" not allowed here; expected the element end-tag' }
      end
    end
  end

  describe '.new_version_from_xml_string' do
    let(:xml) { '<card/>' }

    it 'creates a new card_version on the card' do
      expect_any_instance_of(XmlCardLoader).to receive(:load).with(xml, replace_latest_version: false)
      XmlCardLoader.new_version_from_xml_string('<card/>', card)
    end
  end

  describe '.replace_draft_from_xml_string' do
    let(:xml) { '<card/>' }

    it 'creates a new card_version on the card' do
      expect_any_instance_of(XmlCardLoader).to receive(:load).with(xml, replace_latest_version: true)
      XmlCardLoader.replace_draft_from_xml_string('<card/>', card)
    end
  end

  describe 'creating or replacing a card_version using :replace_latest_version flag' do
    let(:xml) { "<card name='Foo' required-for-submission='true' workflow-display-only='true'>#{content1}</card>" }

    it 'when true, it replaces current card_version' do
      expect {
        xml_card_loader.load(xml, replace_latest_version: true)
      }.to_not change {
        card.reload.card_versions.count
      }.from(1)
    end

    it 'when false, it adds a new card_version' do
      expect {
        xml_card_loader.load(xml, replace_latest_version: false)
      }.to change {
        card.reload.card_versions.count
      }.from(1).to(2)
    end
  end

  describe 'setting card attributes' do
    let(:xml) { "<card name='Foo' required-for-submission='true' workflow-display-only='true'>#{content1}</card>" }

    it 'sets #name' do
      expect {
        xml_card_loader.load(xml)
      }.to change {
        card.reload.name
      }.from('original name').to('Foo')
    end
  end

  describe 'setting card_version attributes' do
    let(:xml) { "<card name='Foo' required-for-submission='true' workflow-display-only='true'>#{content1}</card>" }

    before do
      card.latest_card_version.update(required_for_submission: false, workflow_display_only: false)
    end

    it 'sets #required_for_submission' do
      expect {
        xml_card_loader.load(xml)
      }.to change {
        card.reload.latest_card_version.required_for_submission
      }.from(false).to(true)
    end

    it 'increments #version' do
      expect {
        xml_card_loader.load(xml)
      }.to change {
        card.reload.latest_card_version.version
      }.from(1).to(2)
    end

    it 'sets #workflow_display_only' do
      expect {
        xml_card_loader.load(xml)
      }.to change {
        card.reload.latest_card_version.workflow_display_only
      }.from(false).to(true)
    end
  end

  describe 'setting card_content with validations' do
    let(:root_content) { card.reload.latest_card_version.card_contents.root }
    let(:child_content) { root_content.children.first }
    let(:validations) { child_content.card_content_validations }
    let(:xml) do
      <<-XML
        <card name='Foo' required-for-submission='true' workflow-display-only='true'>
          <content content-type='display-children'>
            <content ident='foo' content-type='short-input' value-type='text'>
              <text>foo</text>
              <validation validation-type='string-match'>
                <error-message>First Validation</error-message>
                <validator>/test-one/</validator>
              </validation>
            </content>
          </content>
        </card>
      XML
    end

    it 'creates string match card content validations' do
      xml_card_loader.load(xml)
      expect(validations.count).to eq(1)
      expect(validations.first.validation_type).to eq 'string-match'
      expect(validations.first.error_message).to eq 'First Validation'
      expect(validations.first.validator).to eq '/test-one/'
    end
  end

  describe 'setting card_content attributes' do
    let(:xml) { "<card name='Foo' required-for-submission='true' workflow-display-only='true'>#{content1}</card>" }
    let(:root_content) { card.reload.latest_card_version.card_contents.root }

    context 'with nested contents' do
      let(:xml) do
        <<-XML
          <card name='Foo' required-for-submission='true' workflow-display-only='true'>
            <content content-type='display-children'>
              #{content1}
              #{content2}
            </content>
          </card>
        XML
      end
      let(:first) { root_content.children[0] }
      let(:second) { root_content.children[1] }

      it 'creates the children' do
        xml_card_loader.load(xml)
        expect(first.ident).to eq('foo')
        expect(first.content_type).to eq('text')
        expect(second.ident).to eq('bar')
        expect(second.content_type).to eq('text')
      end
    end

    describe 'setting specific card_content types' do
      context 'radio' do
        let(:content1) do
          <<-XML
            <content ident='foo' value-type='text' content-type='radio' default-answer-value="1">
              <text>Question!</text>
              <possible-value label="one" value="1"/>
            </content>
          XML
        end

        it 'parses possible values' do
          xml_card_loader.load(xml)
          expect(root_content.possible_values).to eq([{ 'label' => 'one', 'value' => '1' }])
        end

        it 'sets the #default_answer_value' do
          xml_card_loader.load(xml)
          expect(root_content.default_answer_value).to eq("1")
        end
      end

      context 'check-box' do
        let(:text) { Faker::Lorem.sentence }
        let(:label) { Faker::Lorem.sentence }
        let(:content1) do
          <<-XML
            <content content-type='check-box' value-type='boolean'>
              <text>#{text}</text>
              <label>#{label}</label>
            </content>
          XML
        end

        it 'sets the #text' do
          xml_card_loader.load(xml)
          expect(root_content.text).to eq(text)
        end

        it 'sets the #label' do
          xml_card_loader.load(xml)
          expect(root_content.label).to eq(label)
        end
      end

      context 'text' do
        let(:text) { 'Foo' }
        let(:content1) { "<content ident='foo' content-type='text'><text>#{text}</text></content>" }

        it 'sets the text to the value of the element text' do
          xml_card_loader.load(xml)
          expect(root_content.text).to eq(text)
        end

        context 'and there is trailing whitespace' do
          let(:content1) { "<content ident='foo' content-type='text'><text> #{text}  \n</text></content>" }

          it 'is removed' do
            xml_card_loader.load(xml)
            expect(root_content.text).to eq(text)
          end
        end

        context 'and the text element includes CDATA' do
          let(:text) { '<![CDATA[<a>link</a>]]>' }

          it 'includes the embedded HTML' do
            xml_card_loader.load(xml)
            expect(root_content.text).to eq('<a>link</a>')
          end
        end
      end

      context 'short-input' do
        let(:text) { Faker::Lorem.sentence }
        let(:placeholder) { Faker::Lorem.sentence }
        let(:content1) do
          <<-XML
            <content content-type='short-input' value-type='text' default-answer-value="foo">
              <placeholder>#{placeholder}</placeholder>
              <text>#{text}</text>
            </content>
          XML
        end

        it 'sets the text to the value of the element text' do
          xml_card_loader.load(xml)
          expect(root_content.text).to eq(text)
        end

        it 'sets the placeholder to the value of the element placeholder' do
          xml_card_loader.load(xml)
          expect(root_content.placeholder).to eq(placeholder)
        end

        it 'sets the default answer value if given' do
          xml_card_loader.load(xml)
          expect(root_content.default_answer_value).to eq("foo")
        end
      end

      context 'dropdown' do
        let(:content1) do
          <<-XML
            <content ident='foo' value-type='text' content-type='dropdown'>
              <text>Question!</text>
              <possible-value label="one" value="1"/>
            </content>
          XML
        end

        it 'parses possible values' do
          xml_card_loader.load(xml)
          expect(root_content.possible_values).to eq([{ 'label' => 'one', 'value' => '1' }])
        end
      end
    end
  end
end
