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

describe Typesetter::FunderSerializer do
  def funder_question(short_ident, repetition)
    {
      ident: "funder--#{short_ident}",
      answer: "answer for #{short_ident}",
      value_type: 'text',
      repetition: repetition
    }
  end

  let(:task) { FactoryGirl.create(:custom_card_task) }
  let(:repetition) { FactoryGirl.create(:repetition, task: task) }

  let(:funder_questions) do
    [
      funder_question('name', repetition),
      funder_question('grant_number', repetition),
      funder_question('website', repetition),
      funder_question('additional_comments', repetition),
      funder_question('had_influence', repetition),
      funder_question('had_influence--role_description', repetition)
    ]
  end

  let(:funder) { Funder.from_task(task).first }
  subject(:serializer) { described_class.new(funder) }
  let(:output) { serializer.serializable_hash }

  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }

  before { AnswerableFactory.create(task, questions: funder_questions) }

  it 'has the correct fields' do
    expect(output.keys).to contain_exactly(
      :additional_comments,
      :name,
      :funding_statement,
      :grant_number,
      :website,
      :influence,
      :influence_description
    )
  end

  describe 'funding_statement' do
    it "returns a full funding statement" do
      expect(output[:funding_statement]).to eq(
        "#{output[:name]} #{output[:website]} (grant number #{output[:grant_number]}). #{output[:additional_comments]}. #{output[:influence_description]}."
      )
    end
  end

  describe 'name' do
    it "is the funder's name" do
      expect(output[:name]).to eq('answer for name')
    end
  end

  describe 'grant_number' do
    it "is the funder's grant number" do
      expect(output[:grant_number]).to eq('answer for grant_number')
    end
  end

  describe 'website' do
    it "is the funder's website" do
      expect(output[:website]).to eq('answer for website')
    end
  end

  describe 'influence' do
    it 'is a boolean of whether funder had influence' do
      expect(output[:influence]).to eq('answer for had_influence')
    end
  end

  describe 'influence_description' do
    it "is a description of the funder's influence" do
      expect(output[:influence_description]).to eq('answer for had_influence--role_description')
    end
  end
end
