require 'rails_helper'

describe XmlCardLoader do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:content1) { '<content ident="foo" content-type="text"><text>foo</text></content>' }
  let(:content2) { '<content ident="bar" content-type="text"><text>bar</text></content>' }
  let(:xml) { "<card required-for-submission='true' name='Foo'>#{content1}</card>" }
  let(:card) { XmlCardLoader.from_xml_string(xml, journal).tap(&:save!) }
  let(:root) { card.content_root_for_version(:latest) }

  describe ".from_xml_string" do
    context 'with bad xml' do
      let(:xml) { '<foo/>' }

      it 'throws an exception' do
        expect { card }.to raise_exception(Nokogiri::XML::SyntaxError, 'Expecting element card, got foo')
      end
    end

    context 'creating a card' do
      it 'sets the card name' do
        expect(card.name).to eq('Foo')
      end

      it 'sets the required-for-submission' do
        expect(card.latest_card_version.required_for_submission).to be(true)
      end

      it "sets the new card version's published flag to true" do
        expect(card.latest_card_version.published).to be(true)
      end
    end

    context 'a card with a single root' do
      it 'creates a root card content' do
        expect(root.content_type).to eq('text')
        expect(root.ident).to eq('foo')
      end
    end

    context 'with multiple roots' do
      let(:xml) { "<card required-for-submission='true' name='Foo' >#{content1}#{content2}</card>" }

      it 'throws an exception' do
        expect { card }.to raise_exception(Nokogiri::XML::SyntaxError, 'Element card has extra content: content')
      end
    end

    context 'with nested contents' do
      let(:xml) { "<card required-for-submission='true' name='Foo' ><content content-type='display-children'>#{content1}#{content2}</content></card>" }
      let(:first) { root.children[0] }
      let(:second) { root.children[1] }

      it 'creates the children' do
        expect(first.ident).to eq('foo')
        expect(first.content_type).to eq('text')
        expect(second.ident).to eq('bar')
        expect(second.content_type).to eq('text')
      end
    end

    context 'with radio content' do
      let(:content1) do
        <<-XML
        <content ident='foo' value-type='text' content-type='radio'>
          <text>Question!</text>
          <possible-value label=\"one\" value=\"1\"/>
        </content>
      XML
      end

      it 'parses possible values' do
        expect(root.possible_values).to eq([{ 'label' => 'one', 'value' => '1' }])
      end
    end

    context 'with a text element' do
      let(:text) { 'Foo' }
      let(:content1) { "<content ident='foo' content-type='text'><text>#{text}</text></content>" }

      it 'sets the text to the value of the element text' do
        expect(root.text).to eq(text)
      end

      context 'and there is trailing whitespace' do
        let(:content1) { "<content ident='foo' content-type='text'><text> #{text}  \n</text></content>" }

        it 'is removed' do
          expect(root.text).to eq(text)
        end
      end

      context 'and the text element includes CDATA' do
        let(:text) { '<![CDATA[<a>link</a>]]>' }

        it 'includes the embedded HTML' do
          expect(root.text).to eq('<a>link</a>')
        end
      end
    end

    context 'with a short-input' do
      let(:text) { Faker::Lorem.sentence }
      let(:placeholder) { Faker::Lorem.sentence }
      let(:content1) do
        <<-XML
        <content content-type='short-input' value-type='text'>
          <placeholder>#{placeholder}</placeholder>
          <text>#{text}</text>
        </content>
      XML
      end

      it 'sets the text to the value of the element text' do
        expect(root.text).to eq(text)
      end

      it 'sets the placeholder to the value of the element placeholder' do
        expect(root.placeholder).to eq(placeholder)
      end
    end

    context 'with a check-box' do
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

      it 'sets the text to the value of the element text' do
        expect(root.text).to eq(text)
      end
      it 'sets the label to the value of the element label' do
        expect(root.label).to eq(label)
      end
    end

    context 'dumping xml' do
      let(:card) { FactoryGirl.create(:card, :versioned, name: Faker::Lorem.word) }
      let(:opts) { { indent: 0, skip_instruct: 0 } }

      it 'works' do
        expect(card.to_xml(opts)).to be_equivalent_to("<card required-for-submission='false' name=\"#{card.name}\"><content value-type=\"text\"></content></card>")
      end
    end
  end

  describe "versioning" do
    let(:xml) do
      <<-XML
        <card required-for-submission='true' name='New Name'>
          <content content-type="display-children" ident="foo">
          </content>
        </card>
      XML
    end
    let(:card) do
      FactoryGirl.create(
        :card,
        latest_version: 1
      )
    end

    let!(:old_version) do
      FactoryGirl.create(:card_version, card: card, version: 1, required_for_submission: false)
    end

    describe ".new_version_from_xml_string" do
      it "makes a new version with content from the xml" do
        new_version = XmlCardLoader.new_version_from_xml_string(xml, card)

        expect(new_version.card_contents.count).to eq(1)
        expect(new_version.content_root.ident).to eq("foo")
      end

      it "doesn't delete the old version or old content" do
        old_content_count = old_version.card_contents.count
        XmlCardLoader.new_version_from_xml_string(xml, card)

        expect(card.card_versions.count).to eq(2)
        expect(old_content_count).to eq(old_version.card_contents.count)
      end

      it "assigns the card version's attributes based on the xml" do
        new_version = XmlCardLoader.new_version_from_xml_string(xml, card)

        expect(new_version.version).to eq(2)
        expect(card.latest_version).to eq(2)
        expect(new_version.required_for_submission).to eq(true)
      end
    end

    describe ".replace_version_from_xml_string" do
      it "creates content from the new xml and deletes the old content" do
        old_root = old_version.content_root
        updated_version = XmlCardLoader.replace_draft_from_xml_string(xml, card)

        expect(old_root.reload).to be_deleted
        expect(old_root.id).to_not eq(updated_version.content_root.id)
      end

      it "updates the card version's attributes based on the xml" do
        updated_version = XmlCardLoader.replace_draft_from_xml_string(xml, card)

        expect(updated_version.version).to eq(1)
        expect(card.latest_version).to eq(1)
        expect(updated_version.required_for_submission).to eq(true)
      end

      it "works when the new content has the same ident as the old ident" do
        old_version.content_root.update(ident: 'foo')
        updated_version = XmlCardLoader.replace_draft_from_xml_string(xml, card)
        expect(updated_version.content_root.ident).to eq('foo')
      end
    end
  end
end
