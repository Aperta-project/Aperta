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

describe Typesetter::CompetingInterestsSerializer do
  subject(:serializer) { described_class.new(task) }
  let!(:task) do
    AnswerableFactory.create(
      FactoryGirl.create(:competing_interests_task),
      questions: [
        {
          ident: 'competing_interests--has_competing_interests',
          answer: 'true',
          value_type: 'boolean',
          questions: [{
            ident: 'competing_interests--statement',
            answer: '<p><i>entered</i> statement</p>',
            value_type: 'text'
          }]
        }
      ]
    )
  end

  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }
  let(:output) { serializer.serializable_hash }

  it 'has competing interests fields' do
    expect(output.keys).to contain_exactly(
      :competing_interests,
      :competing_interests_statement)
  end

  it 'works without values' do
    allow(task).to receive(:answer_for).and_return(nil)
    output = serializer.serializable_hash

    expect(output[:competing_interests]).to eq(nil)
  end

  describe 'competing interests value' do
    it 'is the answer to the competing interests question' do
      expect(output[:competing_interests]).to eq(true)
    end
  end

  describe 'competing interests statement value' do
    it 'has HTML tags stripped' do
      expect(output[:competing_interests_statement]).to eq('entered statement')
    end
  end

  describe 'no competing interests statement' do
    let!(:no_competing_task) do
      AnswerableFactory.create(
        FactoryGirl.create(:competing_interests_task),
        questions: [
          {
            ident: 'competing_interests',
            answer: 'false',
            value_type: 'boolean',
            questions: [{
              ident: 'statement',
              answer: 'entered statement',
              value_type: 'text'
            }]
          }
        ]
      )
    end

    it 'has the stock no competing interests statement' do
      output = Typesetter::CompetingInterestsSerializer.new(
        no_competing_task).serializable_hash

      expect(output[:competing_interests_statement]).to \
        eq('The authors have declared that no competing interests exist.')
    end
  end
end
