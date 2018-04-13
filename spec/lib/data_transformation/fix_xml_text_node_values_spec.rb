# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'data_transformation/base'
require 'data_transformation/fix_xml_text_node_values'

describe 'DataTransformation::FixXmlTextNodeValues' do
  describe '#remove_cdata_nodes' do
    subject(:data_transformation) { DataTransformation::FixXmlTextNodeValues.new }

    before(:each) do
      data_transformation.counters = {}
    end

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
      data_transformation.remove_cdata_nodes
      expect(card_content.reload.text).to eq expected_text
    end
  end
end
