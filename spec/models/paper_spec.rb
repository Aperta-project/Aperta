require 'spec_helper'

describe Paper do
  let(:paper) { FactoryGirl.build :paper }

  describe "initialization" do
    describe "paper_type" do
      it "is required" do
        paper = Paper.new short_title: 'Example'
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:paper_type)
      end
    end
  end

  describe "add author" do
    it "adds the freaking author" do
      paper = FactoryGirl.create :paper
      author = {first_name: "Isaac", last_name: "Newton", email: "apple@england.co.uk"}.as_json
      expect { paper.add_author author }.to change { Author.count }.by 1
      expect(paper.authors.where(email: "apple@england.co.uk")).to_not be_empty
    end
  end

  describe "validations" do
    describe "short_title" do
      it "must be present" do
        paper = FactoryGirl.build(:paper, short_title: nil)
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:short_title)
      end

      it "must be unique" do
        paper = FactoryGirl.create(:paper, short_title: 'Duplicate')
        dup_paper = FactoryGirl.build(:paper, short_title: 'Duplicate')
        expect(dup_paper).to_not be_valid
        expect(dup_paper).to have(1).errors_on(:short_title)
      end

      it "must be less than 50 characters" do
        paper = FactoryGirl.build(:paper, short_title: 'Longer than 50 characters is not an awesome short title coz short titles should be short, stupid!')
        expect(paper).to_not be_valid
        expect(paper).to have(1).errors_on(:short_title)
      end
    end

    describe "journal" do
      it "must be present" do
        paper = Paper.new(short_title: 'YOLO')
        expect(paper).to_not be_valid
      end
    end

  end

  describe "callbacks" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.build :paper, user: user }

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
    let(:user) { FactoryGirl.create(:user) }
    context "when the paper has an editor" do
      before { PaperRole.create! user: user, paper: paper, editor: true }
      specify { expect(paper.editors).to include(user) }
    end

    context "when the paper doesn't have an editor" do
      specify { expect(paper.editors).to be_empty }
    end
  end

  describe ".assignees" do
    let(:user)  { build(:user) }
    let(:admin_user)  { build(:user, :admin) }
    let(:paper) { build(:paper, user: user) }

    before do
      allow(paper).to receive(:available_admins).and_return([admin_user])
    end

    it "should contain both users and assignees" do
      expect(paper.assignees).to match_array([user, admin_user])
    end
  end
end
