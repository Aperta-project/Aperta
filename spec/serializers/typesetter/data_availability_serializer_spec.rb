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

describe Typesetter::DataAvailabilitySerializer do
  subject(:serializer) { described_class.new(task) }

  let!(:task) do
    AnswerableFactory.create(
      FactoryGirl.create(:data_availability_task),
      questions: [
        {
          ident: 'data_availability--data_fully_available',
          answer: 'true',
          value_type: 'boolean'
        },
        {
          ident: 'data_availability--data_location',
          answer: '<p><i>holodeck</i></p>',
          value_type: 'text'
        }
      ]
    )
  end

  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }
  let(:output) { serializer.serializable_hash }

  it 'has data availability fields' do
    expect(output.keys).to contain_exactly(
      :data_fully_available,
      :data_location_statement)
  end

  it 'works without values' do
    allow(task).to receive(:answer_for).and_return(nil)
    output = serializer.serializable_hash

    expect(output[:data_fully_available]).to eq(nil)
    expect(output[:data_location_statement]).to eq(nil)
  end

  describe 'data fully available value' do
    it 'is the answer to the data fully available question' do
      expect(output[:data_fully_available]).to eq(true)
    end
  end

  describe 'data location statement value' do
    it 'is the answer to the data location statement question and is stripped of tags' do
      expect(output[:data_location_statement]).to eq('holodeck')
    end
  end
end
