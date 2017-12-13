require 'rails_helper'
require 'data_transformation/base'
require 'data_transformation/fix_xml_text_node_values'

describe 'DataTransformation::FixXmlTextNodeValues' do
  describe '#remove_cdata_nodes' do
    subject { DataTransformation::FixXmlTextNodeValues.new }
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

    let(:card_content) { FactoryGirl.create(:card_content) }

    it 'removes cdata nodes' do
      # We want to put the text in an invalid state to make it mirror prod
      # rubocop:disable Rails/SkipsModelValidations:
      card_content.update_attribute('text', text)
      subject.remove_cdata_nodes
      expect(card_content.reload.text).to eq expected_text
    end
  end
end
