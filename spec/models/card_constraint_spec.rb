require 'rails_helper'

describe Card do
  let(:card) { FactoryGirl.create(:card, :versioned) }

  let(:valid_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="display-children">
            <content ident="Some Stuff 1" content-type="paragraph-input" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </content>
            <content ident="Some Stuff 2" content-type="short-input" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </content>
          </content>
        </content>
      </card>
    XML
  end

  let(:dup_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="display-children">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </content>
            <content ident="SomeStuff" content-type="short-input" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </content>
          </content>
        </content>
      </card>
    XML
  end

  let(:if_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="if" condition="isEditable">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </content>
            <content ident="SomeStuff" content-type="short-input" value-type="text">
              <text>This is the ELSE branch of an inner IF condition.</text>
            </content>
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
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].first[:message]).to match(/unique.*SomeStuff/)
    end

    it 'immediate children of an IF component may have the same ident' do
      loader = XmlCardLoader.new(card)
      loader.load(if_xml)
      expect(card.errors).to be_empty
    end
  end
end
