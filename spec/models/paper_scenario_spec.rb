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
