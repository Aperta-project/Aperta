require 'rails_helper'

describe Paper do
  let(:paper) { FactoryGirl.create :paper }
  let(:doi) { 'pumpkin/doughnut.888888' }
  let(:user) { FactoryGirl.create :user }

  describe "#create" do
    it "also create Decision" do
      expect(paper.decisions.length).to eq 1
      expect(paper.decisions.first.class).to eq Decision
    end
  end

  describe "#destroy" do
    subject { paper.destroy }

    it "is successful" do
      expect(subject).to eq paper
      expect(subject.destroyed?).to eq true
    end

    context "with tasks" do
      let(:paper) { FactoryGirl.create(:paper, :with_tasks) }

      it "delete Phases and Tasks" do
        expect(paper).to have_at_least(1).phase
        expect(paper).to have_at_least(1).task
        paper.destroy

        expect(Phase.where(paper_id: paper.id).count).to be 0
        expect(Task.count).to be 0
      end
    end
  end

  describe "validations" do
    describe "paper_type" do
      it "is required" do
        paper = Paper.new short_title: 'Example'
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:paper_type)
      end
    end

    describe "metadata_tasks_completed?" do
      context "paper with completed metadata task" do
        let(:paper) do
          FactoryGirl.create(:paper_with_task, task_params: { type: "MockMetadataTask", completed: true })
        end

        it "returns true" do
          expect(paper.metadata_tasks_completed?).to eq(true)
        end
      end

      context "paper with incomplete metadata task" do
        let(:paper) do
          FactoryGirl.create(:paper_with_task, task_params: { type: "MockMetadataTask", completed: false })
        end

        it "returns false" do
          expect(paper.metadata_tasks_completed?).to eq(false)
        end
      end
    end

    describe "title" do
      it "is within 255 chars" do
        paper = FactoryGirl.build(:paper, title: "a" * 256)
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:title)

        paper.title = "a" * 254
        expect(paper).to be_valid

        paper.title = "a" * 255
        expect(paper).to be_valid
      end
    end

    describe "short_title" do
      it "must be present" do
        paper = FactoryGirl.build(:paper, short_title: nil)
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:short_title)
      end

      it "must be unique" do
        FactoryGirl.create(:paper, short_title: 'Duplicate')
        dup_paper = FactoryGirl.build(:paper, short_title: 'Duplicate')
        expect(dup_paper).to_not be_valid
        expect(dup_paper).to have(1).errors_on(:short_title)
      end

      it "is within 255 chars" do
        paper = FactoryGirl.build(:paper, short_title: "a" * 256)
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:short_title)

        paper.short_title = "a" * 254
        expect(paper).to be_valid

        paper.short_title = "a" * 255
        expect(paper).to be_valid
      end
    end

    describe "journal" do
      it "must be present" do
        paper = Paper.new(short_title: 'YOLO')
        expect(paper).to_not be_valid
      end
    end
  end

  describe "states" do
    context "when submitting" do
      let(:paper) { FactoryGirl.create(:paper) }

      it "does not transition when metadata tasks are incomplete" do
        expect(paper).to receive(:metadata_tasks_completed?).and_return(false)
        expect{ paper.submit! user }.to raise_error(AASM::InvalidTransition)
      end

      it "transitions to submitted" do
        expect(paper).to receive(:metadata_tasks_completed?).and_return(true)
        paper.submit! user
        expect(paper).to be_submitted
      end

      it "marks the paper not editable" do
        expect(paper).to receive(:metadata_tasks_completed?).and_return(true)
        paper.submit! user
        expect(paper).to_not be_editable
      end

      it "submits the paper to salesforce" do
        expect(paper).to receive(:find_or_create_paper_in_salesforce).and_return(true)
        paper.submit! user
      end

      it "submits billing and pfa info to salesforce" do
        expect(paper).to receive(:create_billing_and_pfa_case).and_return(true)
        paper.submit! user
      end

    end

    context "when minor-revising (as in a tech check)" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "marks the paper editable" do
        paper.minor_revision!
        expect(paper).to be_editable
      end
    end

    context "when submitting a minor change (as in a tech check)" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "marks the paper uneditable" do
        paper.minor_check!
        paper.submit_minor_check!
        expect(paper).to_not be_editable
      end
    end

    context "when publishing" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "marks the paper uneditable" do
        paper.publish!
        expect(paper.published_at).to be_truthy
      end
    end
  end

  describe "#make_decision" do
    let(:paper) { FactoryGirl.create(:paper, :submitted) }

    context "acceptance" do
      let(:decision) do
        FactoryGirl.create(:decision, verdict: "accept")
      end

      it "accepts the paper" do
        paper.make_decision decision
        expect(paper.publishing_state).to eq("accepted")
      end
    end

    context "acceptance" do
      let(:decision) do
        FactoryGirl.create(:decision, verdict: "accept")
      end

      it "accepts the paper" do
        paper.make_decision decision
        expect(paper.publishing_state).to eq("accepted")
      end
    end

    context "rejection" do
      let(:decision) do
        FactoryGirl.create(:decision, verdict: "reject")
      end

      it "rejects the paper" do
        paper.make_decision decision
        expect(paper.publishing_state).to eq("rejected")
      end
    end

    context "major revision" do
      let(:decision) do
        FactoryGirl.create(:decision, verdict: "major_revision")
      end

      it "puts the paper in_revision" do
        paper.make_decision decision
        expect(paper.publishing_state).to eq("in_revision")
      end
    end

    context "minor revision" do
      let(:decision) do
        FactoryGirl.create(:decision, verdict: "minor_revision")
      end
      it "puts the paper in_revision" do
        paper.make_decision decision
        expect(paper.publishing_state).to eq("in_revision")
      end
    end

  end


  describe "callbacks" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.build :paper, creator: user }

    it "assigns all author tasks to the paper author" do
      paper.save!
      author_tasks = Task.where(role: 'author', phase_id: paper.phases.pluck(:id))
      other_tasks = Task.where("role != 'author'", phase_id: paper.phases.pluck(:id))
      expect(author_tasks.all? { |t| t.assignee == user }).to eq true
      expect(other_tasks.all? { |t| t.assignee != user }).to eq true
    end

    context "when the paper is persisted" do
      before { paper.save! }

      it "assigns all author tasks to the paper author" do
        tasks = Task.where(role: 'author', phase_id: paper.phases.map(&:id))
        not_author = FactoryGirl.create(:user)
        paper.update! creator: not_author
        expect(tasks.all? { |t| t.assignee == user }).to eq true
      end
    end
  end

  describe "#editor" do
    let(:user) { FactoryGirl.create(:user) }
    context "when the paper has an editor" do
      before { create(:paper_role, :editor, paper: paper, user: user) }
      specify { expect(paper.editors).to include(user) }
    end

    context "when the paper doesn't have an editor" do
      specify { expect(paper.editors).to be_empty }
    end
  end

  describe "#role_for" do
    let(:user) { FactoryGirl.create :user }

    before do
      create(:paper_role, :editor, paper: paper, user: user)
    end

    it "returns roles if the role exist for the given user and role type" do
      expect(paper.role_for(user: user, role: 'editor')).to be_present
    end

    context "when the role isn't found" do
      it "returns nothing" do
        expect(paper.role_for(user: user, role: 'chucknorris')).to_not be_present
      end
    end
  end

  describe "#abstract" do
    before do
      paper.update(body: "a bunch of words")
    end

    context "with an #abstract field value" do
      before do
        paper.update(abstract: "an abstract about a bunch of words")
      end

      it "returns #abstract" do
        expect(paper.abstract).to eq "an abstract about a bunch of words"
      end
    end

    context "without an #abstract field value" do
      it "returns #default_abstract" do
        expect(paper.abstract).to eq "a bunch of words"
      end
    end
  end

  describe "#authors_list" do
    let!(:plos_author1) { FactoryGirl.create :plos_author, paper: paper }
    let!(:plos_author2) { FactoryGirl.create :plos_author, paper: paper }

    it "returns authors' last name, first name and affiliation name in an ordered list" do
      expect(paper.authors_list).to eq "1. #{plos_author1.last_name}, #{plos_author1.first_name} from #{plos_author1.specific.affiliation}\n2. #{plos_author2.last_name}, #{plos_author2.first_name} from #{plos_author2.specific.affiliation}"
    end
  end
end
