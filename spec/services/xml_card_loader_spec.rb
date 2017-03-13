describe XmlCardLoader do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:card) { XmlCardLoader.from_xml_string(xml, journal).tap(&:save!) }
  let(:content1) { '<content ident="foo" value-type="boolean" text="bar"/>' }
  let(:content2) { '<content ident="bar" value-type="text"/>' }
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
      expect(root.value_type).to eq('boolean')
      expect(root.ident).to eq('foo')
      expect(root.text).to eq('bar')
    end
  end

  context 'with multiple roots' do
    let(:xml) { "<card name='Foo'>#{content1}#{content2}</card>" }

    it 'throws an exception' do
      expect { card }.to raise_exception(Nokogiri::XML::SyntaxError, 'Did not expect element content there')
    end
  end

  context 'with nested contents' do
    let(:xml) { "<card name='Foo'><content value-type='question_set'>#{content1}#{content2}</content></card>" }
    let(:first) { root.children[0] }
    let(:second) { root.children[1] }

    it 'creates the children' do
      expect(first.ident).to eq('foo')
      expect(first.value_type).to eq('boolean')
      expect(second.ident).to eq('bar')
      expect(second.value_type).to eq('text')
    end
  end

  context 'with a text element' do
    let(:text) { 'Foo' }
    let(:content1) { "<content ident='foo' value-type='boolean'><text>#{text}</text></content>" }
    let(:xml) { "<card name='Foo'>#{content1}</card." }

    it 'sets the text to the value of the element text' do
      expect(root.text).to eq(text)
    end

    context 'and there is trailing whitespace' do
      let(:content1) { "<content ident='foo' value-type='boolean'><text> #{text}  \n</text></content>" }

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
      expect(card.to_xml(opts)).to eq("<card name=\"#{card.name}\"></card>")
    end
  end
end
