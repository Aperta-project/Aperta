require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionScenario do
  subject(:context) do
    TahiStandardTasks::RegisterDecisionScenario.new(paper)
  end

  let(:task) do
    FactoryGirl.create(
      :register_decision_task,
      :with_stubbed_associations,
      paper: paper
    )
  end
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :with_creator,
      :submitted_lite,
      title: Faker::Lorem.paragraph
    )
  end
  let(:decision) { paper.draft_decision }
  let(:reviewer) { FactoryGirl.create(:user) }
  let(:reviewer_report) { FactoryGirl.build(:reviewer_report, task: task, user: reviewer) }
  let(:reviewer_number) { 33 }
  let(:answer_1) { FactoryGirl.create(:answer) }
  let(:answer_2) { FactoryGirl.create(:answer) }

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
      decision.reviewer_reports << reviewer_report
      template = "{%- for review in reviews -%}Review by {{review.reviewer.first_name}}{%- endfor -%}"
      expect(Liquid::Template.parse(template).render(context))
        .to eq("Review by #{reviewer.first_name}")
    end
  end
end
