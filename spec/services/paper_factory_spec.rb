require 'rails_helper'

describe PaperFactory do
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions, :with_doi) }
  let(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  let!(:role) do
    FactoryGirl.create(:role, name: Role::CREATOR_ROLE, journal: journal)
  end

  let(:user) { FactoryGirl.create :user }

  describe ".create" do
    let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: mmt.paper_type) }
    subject do
      PaperFactory.create(paper_attrs, user)
    end

    it "makes the creator a collaborator on the paper" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.collaborators.first).to eq(user)
    end

    it "makes the creator an author on the paper" do
      new_paper = PaperFactory.create(paper_attrs, user)
      author = new_paper.authors.last
      expect(author.first_name).to eq(user.first_name)
      expect(author.last_name).to eq(user.last_name)
      expect(author.email).to eq(user.email)
    end

    it "reifies the phases for the given paper from the correct MMT" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.phases.size).to eq(2)
      expect(new_paper.phases.first.name).to eq(mmt.phase_templates.first.name)
    end

    it "reifies the tasks for the given paper from the correct MMT" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.tasks.size).to eq(2)
      expect(new_paper.tasks.pluck(:type)).to match_array(['TahiStandardTasks::PaperAdminTask', 'TahiStandardTasks::DataAvailabilityTask'])
    end

    it "sets user as a participant on tasks with old_role = author" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.tasks.find_by(type: 'TahiStandardTasks::PaperAdminTask').participants).to be_empty
      expect(new_paper.tasks.find_by(type: 'TahiStandardTasks::DataAvailabilityTask').participants).to include(user)
    end

    it "adds correct positions to new tasks" do
      new_paper = PaperFactory.create(paper_attrs, user)
      new_paper.phases.each do |phase|
        expect(phase.tasks.pluck(:position).uniq.count).to eq(phase.tasks.count)
      end
    end

    it "sets the creator" do
      expect(subject.creator).to eq(user)
    end

    it "creates a Decision" do
      expect(subject.decisions.length).to eq 1
    end

    it "applies the template" do
      expect(subject.phases.count).to eq(2)
    end

    it "assigns a DOI to paper" do
      expect(subject.doi).to_not be_nil
    end

    it "saves the paper" do
      expect(subject).to be_persisted
    end

    context "with non-existant template" do
      let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: "Opinion Piece") }
      it "adds an error on paper_type" do
        expect(subject.errors[:paper_type]).to eq(["is not valid"])
      end
    end

    context "without a journal" do
      let(:paper_attrs) do
        FactoryGirl.attributes_for(:paper,
                                   journal_id: nil,
                                   paper_type: mmt.paper_type)
      end

      specify { expect(subject).to_not be_valid }
      specify { expect(subject.errors[:journal]).to eq(["can't be blank"]) }
    end
  end
end
