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
      expect(Liquid::Template.parse(template).render(context))
        .to eq(journal.name)
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

    it "renders the invitation status" do
      template = "{{ invitation.state }}"
      expect(Liquid::Template.parse(template).render(context))
        .to eq(invitation.state)
    end
  end
end
