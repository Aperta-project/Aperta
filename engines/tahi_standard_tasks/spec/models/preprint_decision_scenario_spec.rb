require 'rails_helper'
# rubocop:disable Metrics/BlockLength
describe TahiStandardTasks::PreprintDecisionScenario do
  subject(:context) do
    TahiStandardTasks::PreprintDecisionScenario.new(paper)
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

  describe "rendering a PreprintDecisionScenario" do
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
  end
end
