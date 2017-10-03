require 'rails_helper'

describe TahiStandardTasks::PaperReviewerScenario do
  subject(:context) do
    TahiStandardTasks::PaperReviewerScenario.new(invitation)
  end

  let(:paper) do
    FactoryGirl.create(:paper, :with_academic_editor_user, journal: journal)
  end
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:invitation) { FactoryGirl.create(:invitation, :invited, paper: paper) }

  describe "rendering a template" do
    it "renders the journal" do
      template = "{{ journal.name }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(journal.name)
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

    it "renders the invitation status" do
      template = "{{ invitation.state }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(invitation.state)
    end
  end
end
