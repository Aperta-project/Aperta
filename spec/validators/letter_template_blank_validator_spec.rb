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

describe LetterTemplateBlankValidator do
  subject do
    parsed_template = Liquid::Template.parse(letter_template.subject)
    described_class.blank_fields?(parsed_template, letter_context)
  end
  let(:letter_template) { FactoryGirl.create :letter_template }

  context 'with missing information' do
    let(:letter_context) do
      { 'subject': '' }
    end
    context 'at the top level' do
      before { letter_template.subject = '{{ subject }}' }

      it { should be true }
    end

    context 'within a for loop' do
      before { letter_template.subject = '{% for i in [0,1] %}{{ subject }}{% endfor %}' }

      it { should be true }
    end

    context 'within an unrelated if statement' do
      before { letter_template.subject = '{% if true %}{{ subject }}{% endif %}' }

      it { should be true }
    end
  end

  context 'with information' do
    let(:letter_context) do
      { subject: 'Great paper!' }
    end
    context 'at the top level' do
      before { letter_template.subject = '{{ subject }}' }

      it { should be false }
    end

    context 'within a for loop' do
      before { letter_template.subject = '{% for i in [0,1] %}{{ subject }}{% endfor %}' }

      it { should be false }
    end

    context 'within an unrelated if statement' do
      before { letter_template.subject = '{% if true %}{{ subject }}{% endif %}' }

      it { should be false }
    end
  end

  context 'when working with scenarios' do
    let(:reviewer_report) { FactoryGirl.create :reviewer_report }
    let(:letter_context) { ReviewerReportScenario.new(reviewer_report) }
    before do
      reviewer_report.paper.journal.tap { |j| j.update_attribute(:name, nil) }
    end
    context 'with missing information' do
      context 'at the top level' do
        before { letter_template.subject = '{{ journal.name }}' }

        it { should be true }
      end

      context 'within a for loop' do
        before { letter_template.subject = '{% for i in [0,1] %}{{ journal.name }}{% endfor %}' }

        it { should be true }
      end

      context 'within an unrelated if statement' do
        before { letter_template.subject = '{% if true %}{{ journal.name }}{% endif %}' }

        it { should be true }
      end
    end
  end
end
