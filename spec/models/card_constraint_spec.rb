require 'rails_helper'

describe Card do
  let(:card) { FactoryGirl.create(:card, :versioned) }

  let(:valid_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <DisplayChildren>
          <DisplayChildren>
            <ParagraphInput ident="Some Stuff 1" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </ParagraphInput>
            <ShortInput ident="Some Stuff 2" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </ShortInput>
          </DisplayChildren>
        </DisplayChildren>
      </card>
    XML
  end

  let(:dup_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <DisplayChildren>
          <DisplayChildren>
            <ParagraphInput ident="SomeStuff" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </ParagraphInput>
            <ShortInput ident="SomeStuff" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </ShortInput>
          </DisplayChildren>
        </DisplayChildren>
      </card>
    XML
  end

  let(:if_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="if" condition="pdfAllowed">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </ParagraphInput>
            <ShortInput ident="SomeStuff" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </ShortInput>
          </If>
        </DisplayChildren>
      </card>
    XML
  end

  let(:dup_if_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <DisplayChildren>
          <If condition="isEditable">
            <ParagraphInput ident="SomeStuff" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </ParagraphInput>
            <ShortInput ident="SomeStuff" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </content>
          </content>
          <content ident="SomeStuff" content-type="short-input" value-type="text">
            <text>This is some text with an invalid matching ident.</text>
          </content>
        </content>
      </card>
    XML
  end

  context 'validation' do
    it 'will validate card with unique idents' do
      loader = XmlCardLoader.new(card)
      loader.load(valid_xml)
      expect(card.errors).to be_empty
    end

    it 'requires idents to be unique per card' do
      loader = XmlCardLoader.new(card)
      loader.load(dup_xml)
      expect(card).to_not be_valid
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].any? { |error| error[:message].match(/unique.*SomeStuff/) })
    end

    it 'idents cannot duplicate IF idents' do
      loader = XmlCardLoader.new(card)
      loader.load(dup_if_xml)
      expect(card).to_not be_valid
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].any? { |error| error[:message].match(/unique.*SomeStuff/) })
    end

    it 'IFs with isEditable condition cannot have input children' do
      loader = XmlCardLoader.new(card)
      loader.load(dup_if_xml)
      expect(card).to_not be_valid
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].any? { |error| error[:message].match(/isEditable/) })
    end

    it 'immediate children of an IF component may have the same ident' do
      loader = XmlCardLoader.new(card)
      loader.load(if_xml)
      expect(card.errors).to be_empty
    end
  end
end
