require 'spec_helper'

describe Paper do
  let(:paper) { Paper.new short_title: 'Example', journal: Journal.new }

  describe "initialization" do
    describe "paper_type" do
      context "when no paper_type is specified" do
        it "defaults to research" do
          expect(paper.paper_type).to eq 'research'
        end
      end

      context "when paper_type is the empty string" do
        it "defaults to research" do
          paper = Paper.new short_title: 'Example', paper_type: ''
          expect(paper.paper_type).to eq 'research'
        end
      end

      context "when paper_type is specified" do
        it "uses specified paper_type" do
          paper = Paper.new short_title: 'Example', paper_type: 'foobar'
          expect(paper.paper_type).to eq 'foobar'
        end
      end
    end

    describe "task manager" do
      it "initializes a new task manager" do
        expect(paper.task_manager).to be_a TaskManager
      end

      context "when a task manager is specified" do
        it "uses the provided task manager" do
          task_manager = TaskManager.new
          paper = Paper.new short_title: 'Example', task_manager: task_manager
          expect(paper.task_manager).to eq task_manager
        end
      end
    end
  end

  describe "validations" do
    describe "short_title" do
      it "must be unique" do
        expect(Paper.new(journal: Journal.create!)).to_not be_valid
      end

      it "must be present" do
        Paper.create! short_title: 'Duplicate', journal: Journal.create!
        expect(Paper.new short_title: 'Duplicate', journal: Journal.create!).to_not be_valid
      end

      it "must be less than 50 characters" do
        paper = Paper.new short_title: 'Longer than 50 characters is not an awesome short title coz short titles should be short, stupid!',
          journal: Journal.create!
        expect(paper).to_not be_valid
      end
    end

    describe "journal" do
      it "must be present" do
        paper = Paper.new(short_title: 'YOLO')
        expect(paper).to_not be_valid
      end
    end

    describe "paper_type" do
      it "must be one of Paper::PAPER_TYPES" do
        Paper::PAPER_TYPES.each do |type|
          paper.paper_type = type
          expect(paper).to be_valid
        end
        paper.paper_type = 'invalid paper type'
        expect(paper.error_on(:paper_type).size).to eq(1)
      end
    end
  end

  describe "callbacks" do
    let(:user) { User.create! email: 'author@example.com', password: 'password', password_confirmation: 'password', username: 'author' }
    let(:paper)   { Paper.new short_title: 'Paper', journal: Journal.create!, user: user }

    it "assigns all author tasks to the paper author" do
      paper.save!
      author_tasks = Task.where(role: 'author', phase_id: paper.task_manager.phases.pluck(:id))
      other_tasks = Task.where("role != 'author'", phase_id: paper.task_manager.phases.pluck(:id))
      expect(author_tasks.all? { |t| t.assignee == user }).to eq true
      expect(other_tasks.all? { |t| t.assignee != user }).to eq true
    end

    context "when the paper is persisted" do
      before { paper.save! }

      it "assigns all author tasks to the paper author" do
        tasks = Task.where(role: 'author', phase_id: paper.task_manager.phases.map(&:id))
        not_author = User.create! email: 'not_author@example.com', password: 'password', password_confirmation: 'password', username: 'not_author'
        paper.update! user: not_author
        expect(tasks.all? { |t| t.assignee == user }).to eq true
      end
    end
  end

  describe "scopes" do
    let(:ongoing_paper)   { create :paper, submitted: false }
    let(:submitted_paper) { create :paper, submitted: true }
    let(:published_paper) { create :paper, published_at: 2.days.ago }
    let(:unpublished_paper) { create :paper }

    describe ".submitted" do
      it "returns submitted papers only" do
        expect(Paper.submitted).to_not include(ongoing_paper)
        expect(Paper.submitted).to include(submitted_paper)
      end
    end

    describe ".ongoing" do
      it "returns submitted papers only" do
        expect(Paper.ongoing).to_not include(submitted_paper)
        expect(Paper.ongoing).to include(ongoing_paper)
      end
    end

    describe ".published" do
      it "returns published papers only" do
        expect(Paper.published).to include published_paper
        expect(Paper.published).to_not include unpublished_paper
      end
    end

    describe ".unpublished" do
      it "returns published papers only" do
        expect(Paper.unpublished).to include unpublished_paper
        expect(Paper.unpublished).to_not include published_paper
      end
    end
  end

  describe "#editor" do
    let(:user) { User.create! username: 'bob', email: 'bobdylan@example.com', password: 'password', password_confirmation: 'password' }
    context "when the paper has an editor" do
      before { PaperRole.create! user: user, paper: paper, editor: true }
      specify { expect(paper.editor).to eq(user) }
    end

    context "when the paper doesn't have an editor" do
      specify { expect(paper.editor).to be_nil }
    end
  end

  describe ".assignees" do
    let(:user)  { FactoryGirl.build(:user) }
    let(:admin_user)  { FactoryGirl.build(:user, :admin) }
    let(:paper) { FactoryGirl.build(:paper, user: user) }

    before do
      allow(paper).to receive(:admin_assignees).and_return([admin_user])
    end

    it "should contain both users and assignees" do
      expect(paper.assignees).to match_array([user, admin_user])
    end
  end
end
