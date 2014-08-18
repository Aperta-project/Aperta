require 'spec_helper'

describe PaperFactory do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      tasks = [StandardTasks::PaperAdminTask, StandardTasks::DataAvailabilityTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  let(:user) { FactoryGirl.create :user }

  describe "#apply_template" do
    let(:paper) { FactoryGirl.create(:paper, journal: journal, paper_type: mmt.paper_type) }
    let(:paper_factory) { PaperFactory.new(paper, user) }

    it "reifies the phases for the given paper from the correct MMT" do
      expect {
        paper_factory.apply_template
      }.to change { paper.phases.count }.by(2)

      expect(paper.phases.first.name).to eq(mmt.phase_templates.first.name)
    end

    it "reifies the tasks for the given paper from the correct MMT" do
      expect {
        paper_factory.apply_template
      }.to change { paper.tasks.count }.by(2)

      expect(paper.tasks.pluck(:type)).to match_array(['StandardTasks::PaperAdminTask', 'StandardTasks::DataAvailabilityTask'])
    end

    it "sets assignee to tasks with role = author" do
      paper_factory.apply_template
      expect(paper.tasks.where(type: 'StandardTasks::PaperAdminTask').first.assignee).to be_nil
      expect(paper.tasks.where(type: 'StandardTasks::DataAvailabilityTask').first.assignee).to eq(user)
    end
  end

  describe ".create" do
    let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: mmt.paper_type) }
    subject do
      PaperFactory.create(paper_attrs, user)
    end

    it "creates an author" do
      expect { subject }.to change { Author.count }.by 1
    end

    it "makes the creator a collaborator on the paper" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(PaperRole.collaborators.for_user(user).where(paper: new_paper).first).to be_present
    end

    it "sets the user as the first author on the paper's first author group" do
      expect(subject.author_groups.first).to eq Author.last.author_group
      expect(Author.last.first_name).to eq(user.first_name)
    end

    it "sets the user" do
      expect(subject.user).to eq(user)
    end

    it "sets the author" do
      expect(subject.authors.first["first_name"]).to eq(user.first_name)
    end

    it "applies the template" do
      expect(subject.phases.count).to eq(2)
    end

    it "saves the paper" do
      expect(subject).to be_persisted
    end

    it "creates author groups" do
      expect {
        subject
      }.to change { AuthorGroup.count }.by 3
    end

    context "with non-existant template" do
      let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: "Opinion Piece") }
      it "adds an error on paper_type" do
        expect(subject.errors[:paper_type].length).to eq(1)
      end
    end
  end
end
