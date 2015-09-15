require 'rails_helper'

describe PaperFactory do
  let(:journal) { FactoryGirl.create(:journal, :with_doi) }
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

      expect(paper.tasks.pluck(:type)).to match_array(['TahiStandardTasks::PaperAdminTask', 'TahiStandardTasks::DataAvailabilityTask'])
    end

    it "sets user as a participant on tasks with role = author" do
      paper_factory.apply_template
      expect(paper.tasks.where(type: 'TahiStandardTasks::PaperAdminTask').first.participants).to be_empty
      expect(paper.tasks.where(type: 'TahiStandardTasks::DataAvailabilityTask').first.participants).to include(user)
    end

    it "uses the task template's title" do
      custom_title = "Zeitung Administratoraufgabe"
      template = mmt.phase_templates.first.task_templates.find_by(title: "Assign Admin")
      template.update_attribute(:title, custom_title)
      paper_factory.apply_template
      expect(paper.tasks.where(type: 'TahiStandardTasks::PaperAdminTask').first.title).to eq(custom_title)
    end

    it "adds correct positions to new tasks" do
      paper_factory.apply_template
      paper.phases.each do |phase|
        expect(phase.tasks.pluck(:position).uniq.count).to eq(phase.tasks.count)
      end
    end
  end

  describe ".create" do
    let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: mmt.paper_type) }
    subject do
      PaperFactory.create(paper_attrs, user)
    end

    it "makes the creator a collaborator on the paper" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(PaperRole.collaborators.for_user(user).where(paper: new_paper).first).to be_present
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
        expect(subject.errors[:paper_type].length).to eq(1)
      end
    end

    context "without a journal" do
      let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: nil, paper_type: mmt.paper_type) }

      specify { expect(subject).to_not be_valid }
      specify { expect(subject.errors[:journal].length).to eq(1) }
    end
  end
end
