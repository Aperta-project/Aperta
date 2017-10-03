require 'rails_helper'
# rubocop:disable Metrics/BlockLength
describe ReviewerReportScenario do
  subject(:context) { ReviewerReportScenario.new(reviewer_report) }

  describe 'rendering' do
    let(:reviewer_report) { FactoryGirl.create(:reviewer_report) }

    it 'renders the due date' do
      due_at = 2.weeks.from_now.to_s(:due_with_hours)
      reviewer_report.due_datetime = DueDatetime.new(due_at: due_at)
      source = '{{ review.due_at }}'
      expect(LetterTemplate.new(body: source).render(context).body).to eq(due_at)
    end

    it 'renders the journal name' do
      journal = reviewer_report.paper.journal
      source = '{{ journal.name }}'
      expect(LetterTemplate.new(body: source).render(context).body).to eq(journal.name)
    end

    it 'renders the reviewer last name' do
      reviewer = reviewer_report.user
      source = '{{ reviewer.last_name }}'
      expect(LetterTemplate.new(body: source).render(context).body).to eq(reviewer.last_name)
    end

    it 'renders the reviewer email' do
      reviewer = reviewer_report.user
      source = '{{ reviewer.email }}'
      expect(LetterTemplate.new(body: source).render(context).body).to eq(reviewer.email)
    end

    it 'renders the paper title' do
      paper = reviewer_report.paper
      source = '{{ manuscript.title }}'
      expect(LetterTemplate.new(body: source).render(context).body).to eq(paper.title)
    end
  end
end
