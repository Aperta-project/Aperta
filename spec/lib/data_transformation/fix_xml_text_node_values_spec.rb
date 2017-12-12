require 'rails_helper'

describe 'FixXmlTextNodeValues' do

  describe 'remove_cdata_nodes' do
    subject { FixXmlTextNodeValues.new }
    let(:text) do
      <<-TEXT
          <![CDATA[Thank you very much for submitting your manuscript for consideration at PLOS Biology.
          [14:31:29] <br/> In light of the technical checks performed by the PLOS editorial staff,
          we need you to address the specific points listed below. Please resubmit a revised version of
          your manuscript after addressing those points.]]>
      TEXT
    end
    let(:expected_text) do
      <<-TEXT
          Thank you very much for submitting your manuscript for consideration at PLOS Biology.
          [14:31:29] <br/> In light of the technical checks performed by the PLOS editorial staff,
          we need you to address the specific points listed below. Please resubmit a revised version of
          your manuscript after addressing those points.
      TEXT
    end

    let(:card_content) { FactoryGirl.create(:card_content, text: text) }

    it 'removes cdata nodes' do
      subject.call
      expect(card_content.reload.text).to eq expected_text
    end
  end
end
