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

describe ReviewerReportContext do
  subject(:context) do
    ReviewerReportContext.new(reviewer_report)
  end

  let(:reviewer) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:reviewer_report_task, completed: true) }
  let(:reviewer_report) { FactoryGirl.build(:reviewer_report, task: task, submitted_at: Date.current) }
  let(:reviewer_number) { 33 }
  let(:answer_1) { FactoryGirl.create(:answer) }
  let(:answer_2) { FactoryGirl.create(:answer) }

  context 'rendering a reviewer report' do
    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    before do
      allow(task).to receive(:reviewer_number).and_return reviewer_number
    end

    it 'renders a reviewer' do
      check_render("{{ reviewer.first_name }}", reviewer_report.user.first_name)
    end

    it 'renders a reviewer number' do
      check_render("{{ reviewer_number }}", task.reviewer_number.to_s)
    end

    it 'renders a answers' do
      answers = [answer_1, answer_2]
      reviewer_report.answers = answers
      check_render("{{ answers | size }}", answers.count.to_s)
    end

    describe 'reviewer name' do
      before(:each) { reviewer_report.answers = [answer_1, answer_2] }
      let(:raw_value) { 'wat' }

      it 'renders without tags when ident card present' do
        allow(answer_1).to receive_message_chain('card_content.ident').and_return('--identity')
        allow(answer_1).to receive(:value).and_return("<p>#{raw_value}</p>")
        check_render("{{ reviewer_name }}", raw_value)
      end

      it 'renders nothing without ident card' do
        check_render("{{ reviewer_name }}", '')
      end
    end
  end
end
