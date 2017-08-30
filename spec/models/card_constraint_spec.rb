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

  let(:dup_if_xml) do
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
          <content ident="SomeStuff" content-type="short-input" value-type="text">
            <text>This is the ELSE branch of an inner IF condition.</text>
          </content>
        </content>
      </card>
    XML
  end

  let(:valid_single_repeat_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="repeat">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the first INPUT element.</text>
            </content>
          </content>
          <content content-type="repeat">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the second INPUT element.</text>
            </content>
          </content>
        </content>
      </card>
    XML
  end

  let(:valid_multiple_repeat_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="repeat">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the first INPUT element.</text>
            </content>
          </content>
          <content content-type="repeat">
            <content ident="SomeStuff" content-type="paragraph-input" value-type="html">
              <text>This is the second INPUT element.</text>
            </content>
          </content>
        </content>
      </card>
    XML
  end

  let(:invalid_repeat_xml) do
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <card required-for-submission="false" workflow-display-only="false">
        <content content-type="display-children">
          <content content-type="repeat">
            <content content-type="paragraph-input" value-type="html">
              <text>This is the THEN branch of an inner IF condition.</text>
            </content>
            <content content-type="repeat">
              <content content-type="paragraph-input" value-type="html">
                <text>This is a nested repeat component.</text>
              </content>
            </content>
          </content>
        </content>
      </card>
    XML
  end

  context 'if validation' do
    it 'will validate card with unique idents' do
      loader = XmlCardLoader.new(card)
      loader.load(valid_xml)
      expect(card.errors).to be_empty
    end

    it 'immediate children of an IF component may have the same ident' do
      loader = XmlCardLoader.new(card)
      loader.load(if_xml)
      expect(card.errors).to be_empty
    end

    it 'requires idents to be unique per card' do
      loader = XmlCardLoader.new(card)
      loader.load(dup_xml)
      expect(card).to_not be_valid
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].first[:message]).to match(/unique.*SomeStuff/)
    end

    it 'idents cannot duplicate IF idents' do
      loader = XmlCardLoader.new(card)
      loader.load(dup_xml)
      expect(card).to_not be_valid
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].first[:message]).to match(/unique.*SomeStuff/)
    end
  end

  context 'repeat validation' do
    it 'will validate card with a single repeat' do
      loader = XmlCardLoader.new(card)
      loader.load(valid_single_repeat_xml)
      expect(card.errors).to be_empty
    end

    it 'will validate card with non-nested repeats' do
      loader = XmlCardLoader.new(card)
      loader.load(valid_multiple_repeat_xml)
      expect(card.errors).to be_empty
    end

    it 'repeats cannot be nested' do
      loader = XmlCardLoader.new(card)
      loader.load(invalid_repeat_xml)
      expect(card).to_not be_valid
      expect(card.errors).to_not be_empty
      expect(card.errors[:detail]).to be_present
      expect(card.errors[:detail].first[:message]).to match(/.*Repeat.*nested.*/)
    end
  end
end
