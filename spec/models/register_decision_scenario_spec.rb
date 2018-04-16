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

describe RegisterDecisionScenario do
  subject(:context) do
    RegisterDecisionScenario.new(paper)
  end

  let(:paper) do
    FactoryGirl.create(
      :paper,
      :with_creator,
      :submitted_lite,
      title: Faker::Lorem.paragraph,
      journal: FactoryGirl.create(:journal, :with_roles_and_permissions)
    )
  end

  describe "rendering a RegisterDecisionScenario" do
    it "renders the journal" do
      template = "{{ journal.name }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.journal.name)
    end

    it "renders the manuscript type" do
      template = "{{ manuscript.paper_type }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.paper_type)
    end

    it "renders the manuscript title" do
      template = "{{ manuscript.title }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.title)
    end

    it "renders the reviews" do
      reports = [FactoryGirl.create(:reviewer_report), FactoryGirl.create(:reviewer_report)]
      allow(paper).to receive_message_chain(:draft_decision, :reviewer_reports, :submitted).and_return(reports)
      names = reports.map { |r| r.user.first_name }
      template = "{%- for review in reviews -%} Review by {{review.reviewer.first_name}},{%- endfor -%}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq("Review by #{names[0]},Review by #{names[1]},")
    end
  end

  describe '#reviews' do
    it 'orders them by reviewer number, then submitted at' do
      role = FactoryGirl.create(:role, name: Role::REVIEWER_REPORT_OWNER_ROLE)
      review_date = Date.current
      reports = (1..5).map do
        FactoryGirl.create(:reviewer_report,
          submitted_at: review_date,
          state: 'submitted',
          decision: paper.draft_decision,
          task: FactoryGirl.create(:reviewer_report_task, paper: paper)).tap do |report|
          report.task.assignments.create!(role: role, user: report.user)
        end
      end

      # rubocop:disable Rails/SkipsModelValidations
      reports[3].update_column(:submitted_at, review_date - 1.day)
      reports.values_at(1, 0, 4).each { |r| r.task.new_reviewer_number }

      ordered_reviews = reports.values_at(1, 0, 4, 3, 2)
      expect(context.reviews.map { |r| r.send(:object) }).to eq(ordered_reviews)
    end
  end
end
