require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionScenario do
  subject(:context) do
    TahiStandardTasks::RegisterDecisionScenario.new(paper)
  end

  let(:reviewer_report_task) { FactoryGirl.create(:reviewer_report_task, paper: paper) }
  let(:reviewer_report_task2) { FactoryGirl.create(:reviewer_report_task, paper: paper) }
  let(:reviewer_report_task3) { FactoryGirl.create(:reviewer_report_task, paper: paper) }
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :with_creator,
      :submitted_lite,
      title: Faker::Lorem.paragraph,
      number_reviewer_reports: true
    )
  end
  let(:decision) { paper.draft_decision }
  let(:reviewer1) { FactoryGirl.create(:user) }
  let(:reviewer2) { FactoryGirl.create(:user) }
  let(:reviewer3) { FactoryGirl.create(:user) }

  let(:reviewer_report1) { FactoryGirl.build(:reviewer_report, task: reviewer_report_task, user: reviewer1) }
  let(:reviewer_report2) { FactoryGirl.build(:reviewer_report, task: reviewer_report_task2, user: reviewer2) }
  let(:reviewer_report3) { FactoryGirl.build(:reviewer_report, task: reviewer_report_task3, user: reviewer3) }

  let(:reviewer_number1) { 1 }
  let(:reviewer_number2) { 2 }
  let(:reviewer_number3) { 3 }
  let(:answer_1) { FactoryGirl.create(:answer) }
  let(:answer_2) { FactoryGirl.create(:answer) }

  before do
    allow(reviewer_report_task).to receive(:reviewer_number).and_return reviewer_number1
    allow(reviewer_report_task2).to receive(:reviewer_number).and_return reviewer_number2
    allow(reviewer_report_task3).to receive(:reviewer_number).and_return reviewer_number3
  end

  describe "rendering a RegisterDecisionScenario" do
    it "renders the journal" do
      template = "{{ journal.name }}"
      expect(Liquid::Template.parse(template).render(context))
        .to eq(paper.journal.name)
    end

    it "renders the manuscript type" do
      template = "{{ manuscript.paper_type }}"
      expect(Liquid::Template.parse(template).render(context))
        .to eq(paper.paper_type)
    end

    it "renders the manuscript title" do
      template = "{{ manuscript.title }}"
      expect(Liquid::Template.parse(template).render(context))
        .to eq(paper.title)
    end

    it "renders the reviews" do
      decision.reviewer_reports << reviewer_report1
      template = "{%- for review in reviews -%}Review by {{review.reviewer.first_name}}{%- endfor -%}"
      expect(Liquid::Template.parse(template).render(context))
        .to eq("Review by #{reviewer1.first_name}")
    end
  end
end
