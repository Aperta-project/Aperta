describe XmlCardLoader do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:card) { XmlCardLoader.from_xml_string(xml, journal).tap(&:save!) }
  let(:content1) { '<content ident="foo" content-type="text"><text>foo</text></content>' }
  let(:content2) { '<content ident="bar" content-type="text"><text>bar</text></content>' }
  let(:root) { card.content_root_for_version(:latest) }

  context 'with bad xml' do
    let(:xml) { '<foo/>' }

    it 'throws an exception' do
      expect { card }.to raise_exception(Nokogiri::XML::SyntaxError, 'Expecting element card, got foo')
    end
  end

  context 'creating a card' do
    let(:xml) { "<card name='Foo'>#{content1}</card>" }

    it 'sets the card name' do
      expect(card.name).to eq('Foo')
    end
  end

  context 'a card with a single root' do
    let(:xml) { "<card name='Foo'>#{content1}</card." }

    it 'creates a root card content' do
      expect(root.content_type).to eq('text')
      expect(root.ident).to eq('foo')
    end
  end

  context 'with multiple roots' do
    let(:xml) { "<card name='Foo'>#{content1}#{content2}</card>" }

    it 'throws an exception' do
      expect { card }.to raise_exception(Nokogiri::XML::SyntaxError, 'Element card has extra content: content')
    end
  end

  context 'with nested contents' do
    let(:xml) { "<card name='Foo'><content content-type='display-children'>#{content1}#{content2}</content></card>" }
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
    let(:content1) { "<content ident='foo' value-type='text' content-type='radio'><possible-value label=\"one\" value=\"1\"/></content>" }
    let(:xml) { "<card name='Foo'>#{content1}</card." }

    it 'parses possible values' do
      expect(root.possible_values).to eq([{ 'label' => 'one', 'value' => '1' }])
    end
  end

  context 'with a text element' do
    let(:text) { 'Foo' }
    let(:content1) { "<content ident='foo' content-type='text'><text>#{text}</text></content>" }
    let(:xml) { "<card name='Foo'>#{content1}</card." }

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

  context 'dumping xml' do
    let(:card) { FactoryGirl.create(:card, :versioned, name: Faker::Lorem.word) }
    let(:opts) { { indent: 0, skip_instruct: 0 } }

    it 'works' do
      expect(card.to_xml(opts)).to eq("<card name=\"#{card.name}\"><content></content></card>")
    end
  end
end
