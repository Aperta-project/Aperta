require 'rails_helper'

describe PaperFactory do
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      tasks = [TahiStandardTasks::DataAvailabilityTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  let!(:card) { FactoryGirl.create(:card, name: 'TahiStandardTasks::DataAvailabilityTask') }
  let!(:role) { journal.creator_role }
  let(:user) { FactoryGirl.create :user }

  describe ".create" do
    let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: mmt.paper_type) }
    let(:new_paper) { PaperFactory.create(paper_attrs, user) }

    context "when the mmt is configured to use the research reviewer report" do
      it "sets the paper to use the research reviewer report" do
        mmt.update_column :uses_research_article_reviewer_report, true
        paper = PaperFactory.create(paper_attrs, user)
        expect(paper.uses_research_article_reviewer_report).to eq(true)
      end
    end

    context "when the mmt is not configured to use the research reviewer report" do
      it "sets the paper to not to use the research reviewer report" do
        mmt.update_column :uses_research_article_reviewer_report, false
        paper = PaperFactory.create(paper_attrs, user)
        expect(paper.uses_research_article_reviewer_report).to eq(false)
      end
    end

    it "sets the paper's number_reviewer_reports attribute to true" do
      expect(new_paper.number_reviewer_reports).to eq(true)
    end

    it "makes the creator a collaborator on the paper" do
      expect(new_paper.collaborators.first).to eq(user)
    end

    it "makes the creator an author on the paper" do
      expect(new_paper.authors.length).to eq(1)

      author = new_paper.authors.last
      expect(author.first_name).to eq(user.first_name)
      expect(author.last_name).to eq(user.last_name)
      expect(author.email).to eq(user.email)
    end

    it "reifies the phases for the given paper from the correct MMT" do
      expect(new_paper.phases.size).to eq(2)
      expect(new_paper.phases.first.name).to eq(mmt.phase_templates.first.name)
    end

    it "reifies the tasks for the given paper from the correct MMT" do
      expect(new_paper.tasks.size).to eq(1)
      expect(new_paper.tasks.pluck(:type)).to match_array(['TahiStandardTasks::DataAvailabilityTask'])
    end

    it "associates cards to the tasks for the given paper" do
      expect(new_paper.tasks.size).to eq(1)
      new_task = new_paper.tasks.last
      expect(new_task.card.name).to eq('TahiStandardTasks::DataAvailabilityTask')
    end

    it "adds correct positions to new tasks" do
      new_paper.phases.each do |phase|
        expect(phase.tasks.pluck(:position).uniq.count).to eq(phase.tasks.count)
      end
    end

    it "calls the task_added_to_paper hook for each task" do
      expect_any_instance_of(TahiStandardTasks::DataAvailabilityTask).to receive(:task_added_to_paper)
      new_paper
    end

    it "sets the creator" do
      expect(new_paper.creator).to eq(user)
    end

    it "does not create a decision" do
      expect(new_paper.decisions).to be_empty
    end

    it "applies the template" do
      expect(new_paper.phases.count).to eq(2)
    end

    it "assigns a DOI to paper" do
      expect(new_paper.doi).to_not be_nil
    end

    it "saves the paper" do
      expect(new_paper).to be_persisted
    end

    context "with non-existant template" do
      let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: "Opinion Piece") }
      it "adds an error on paper_type" do
        expect(new_paper.errors[:paper_type]).to eq(["is not valid"])
      end
    end

    context "without a journal" do
      let(:paper_attrs) do
        FactoryGirl.attributes_for(:paper,
                                   journal_id: nil,
                                   paper_type: mmt.paper_type)
      end

      specify { expect(new_paper).to_not be_valid }
      specify { expect(new_paper.errors[:journal]).to eq(["can't be blank"]) }
    end
  end
end
