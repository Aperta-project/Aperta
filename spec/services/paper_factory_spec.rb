require 'rails_helper'

describe PaperFactory do
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role, :with_default_task_types) }
  let(:card) { FactoryGirl.create(:card, :versioned) }
  let(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      # create mmt template from specified task classes
      task_klasses = [TahiStandardTasks::PaperReviewerTask]

      # create default cards necessary for a new mmt
      required_task_klasses = task_klasses + [Author]
      required_task_klasses.each { |klass| CardLoader.load(klass.to_s) }

      # create mmt template
      JournalServices::CreateDefaultManuscriptManagerTemplates.create_phase_template(
        name: "First Phase",
        journal: journal,
        mmt: mmt,
        phase_content: task_klasses
      )

      mmt.phase_templates.create!(name: "Phase With No Tasks")

      # add TaskTemplate using a custom Card
      mmt.phase_templates.first.task_templates.create(card: card, title: card.name)

      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  let(:user) { FactoryGirl.create :user }

  describe ".create" do
    let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: mmt.paper_type) }
    subject do
      PaperFactory.create(paper_attrs, user)
    end

    context "when the mmt is configured to use the research reviewer report" do
      it "sets the paper to use the research reviewer report" do
        mmt.update_column :uses_research_article_reviewer_report, true
        paper = PaperFactory.create(paper_attrs, user)
        expect(paper.front_matter?).to eq(false)
      end
    end

    context "when the mmt is not configured to use the research reviewer report" do
      it "sets the paper to not to use the research reviewer report" do
        mmt.update_column :uses_research_article_reviewer_report, false
        paper = PaperFactory.create(paper_attrs, user)
        expect(paper.front_matter?).to eq(true)
      end
    end

    it "sets the paper's number_reviewer_reports attribute to true" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.number_reviewer_reports).to eq(true)
    end

    it "makes the creator a collaborator on the paper" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.collaborators.first).to eq(user)
    end

    it "makes the creator an author on the paper" do
      new_paper = PaperFactory.create(paper_attrs, user)
      expect(new_paper.authors.length).to eq(1)

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
      expect(new_paper.tasks.pluck(:type)).to match_array(['TahiStandardTasks::PaperReviewerTask', 'CustomCardTask'])
    end

    it "associates task templates with tasks" do
      new_paper = PaperFactory.create(paper_attrs, user)
      task_template_titles = new_paper.tasks.map { |t| t.task_template.title }
      expect(task_template_titles).to match_array(['Invite Reviewers', card.name])
    end

    it "adds correct positions to new tasks" do
      new_paper = PaperFactory.create(paper_attrs, user)
      new_paper.phases.each do |phase|
        expect(phase.tasks.pluck(:position).uniq.count).to eq(phase.tasks.count)
      end
    end

    it "calls the task_added_to_paper hook for each task" do
      expect_any_instance_of(TahiStandardTasks::PaperReviewerTask).to receive(:task_added_to_paper)
      subject
    end

    it "sets the creator" do
      expect(subject.creator).to eq(user)
    end

    it "does not create a decision" do
      expect(subject.decisions).to be_empty
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

    it "raises an error without a title" do
      paper = FactoryGirl.build(:paper, title: nil)
      expect(paper).not_to be_valid
      expect(paper.errors[:title]).to eq(["can't be blank"])
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
