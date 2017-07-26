require 'rails_helper'

describe ReviewerReportScenario do
  subject(:context) { ReviewerReportScenario.new(reviewer_report) }

  describe 'rendering' do
    let(:reviewer_report) do
      FactoryGirl.create(:reviewer_report)
    end

    it 'renders the due date' do
      due_at = 2.weeks.from_now
      reviewer_report.due_datetime = DueDatetime.new(due_at: due_at)
      template_source = '{{ review.due_at }}'
      expect(Liquid::Template.parse(template_source).render(context)).to eq(due_at.to_s)
    end

    it 'renders the journal name' do
      journal = reviewer_report.paper.journal
      template_source = '{{ journal.name }}'
      expect(Liquid::Template.parse(template_source).render(context)).to eq(journal.name)
    end

    it 'renders the reviewer last name' do
      reviewer = reviewer_report.user
      template_source = '{{ reviewer.last_name }}'
      expect(Liquid::Template.parse(template_source).render(context)).to eq(reviewer.last_name)
    end

    it 'renders the reviewer email' do
      reviewer = reviewer_report.user
      template_source = '{{ reviewer.email }}'
      expect(Liquid::Template.parse(template_source).render(context)).to eq(reviewer.email)
    end

    it 'renders the paper title' do
      paper = reviewer_report.paper
      template_source = '{{ paper.title }}'
      expect(Liquid::Template.parse(template_source).render(context)).to eq(paper.title)
    end
  end
end
