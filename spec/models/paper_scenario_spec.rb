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
# rubocop:disable Metrics/BlockLength
describe PaperScenario do
  subject(:context) do
    PaperScenario.new(paper)
  end

  let(:task) do
    FactoryGirl.create(
      :preprint_decision_task,
      :with_stubbed_associations,
      paper: paper
    )
  end

  let(:paper) do
    FactoryGirl.create(
      :paper,
      title: Faker::Lorem.paragraph
    )
  end

  describe 'rendering a PreprintScenario' do
    it 'renders the journal' do
      template = '{{ journal.name }}'
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.journal.name)
    end

    it 'renders the manuscript type' do
      template = '{{ manuscript.paper_type }}'
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.paper_type)
    end

    it 'renders the manuscript title' do
      template = '{{ manuscript.title }}'
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.title)
    end
  end
end
