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

    it "can set body on creation" do
      paper_new = FactoryGirl.create :paper, body: 'foo'
      expect(paper_new.body).to eq('foo')
      expect(paper_new.latest_version.text).to eq('foo')
    end

    it "can use body= before save" do
      paper_new = FactoryGirl.build :paper
      paper_new.body = 'foo'
      expect(paper_new.body).to eq('foo')
      paper.save!
      paper.reload
      expect(paper_new.body).to eq('foo')
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

      it "sets the submitting_user of the latest version" do
        paper.submit! user
        expect(paper.latest_version.submitting_user).to eq(user)
      end

      it "sets the updated_at of the latest version" do
        paper.latest_version.update!(updated_at: Time.zone.now - 10.days)
        paper.submit! user
        expect(paper.latest_version.updated_at.utc).to be_within(1.second).of Time.zone.now
      end
    end

    context "when withdrawing" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "transitions to withdrawn without a reason" do
        paper.withdraw!
        expect(paper).to be_withdrawn
      end

      it "transitions to withdrawn with a reason" do
        paper.withdraw! "Don't want to."
        expect(paper.withdrawn?).to eq true
      end

      it "marks the paper not editable" do
        paper.withdraw!
        expect(paper).to_not be_editable
      end
    end

    context "when reactivating" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "transitions to the previous state" do
        paper.withdraw!
        expect(paper).to be_withdrawn
        paper.reload.reactivate!
        expect(paper).to be_submitted
      end

      it "marks the paper with the previous editable state for submitted papers" do
        paper.withdraw!
        expect(paper).to_not be_editable
        paper.reload.reactivate!
        expect(paper).to_not be_editable
        expect(paper.submitted?).to eq(true)
      end

      it "marks the paper with the previous editable state for unsubmitted papers" do
        paper = FactoryGirl.create(:paper, :unsubmitted)
        expect(paper).to be_editable
        paper.withdraw!
        expect(paper).to_not be_editable
        paper.reload.reactivate!
        expect(paper).to be_editable
        expect(paper.unsubmitted?).to eq(true)
      end
    end

    context "when minor-revising (as in a tech check)" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "marks the paper editable" do
        paper.minor_check!
        expect(paper).to be_editable
      end

      it "creates a new minor version" do
        expect(paper.latest_version.version_string).to match(/^R0.0/)
        paper.minor_check!
        expect(paper.latest_version.version_string).to match(/^R0.1/)
      end
    end

    context "when submitting a minor change (as in a tech check)" do
      let(:paper) { FactoryGirl.create(:paper, :submitted) }

      it "marks the paper uneditable" do
        paper.minor_check!
        paper.submit_minor_check! user
        expect(paper).to_not be_editable
      end

      it "sets the submitting_user of the latest version" do
        paper.minor_check!
        paper.submit_minor_check! user
        expect(paper.latest_version.submitting_user).to eq(user)
      end

      it "sets the updated_at of the latest version" do
        paper.minor_check!
        paper.latest_version.update!(updated_at: Time.zone.now - 10.days)
        paper.submit_minor_check! user
        expect(paper.latest_version.updated_at.utc).to be_within(1.second).of Time.zone.now
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

      it "creates a new major version" do
        expect(paper.latest_version.version_string).to match(/^R0.0/)
        paper.make_decision decision
        expect(paper.latest_version.version_string).to match(/^R1.0/)
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

      it "creates a new major version" do
        expect(paper.latest_version.version_string).to match(/^R0.0/)
        paper.make_decision decision
        expect(paper.latest_version.version_string).to match(/^R1.0/)
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
    let!(:author1) { FactoryGirl.create :author, paper: paper }
    let!(:author2) { FactoryGirl.create :author, paper: paper }

    it "returns authors' last name, first name and affiliation name in an ordered list" do
      expect(paper.authors_list).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name} from #{author2.affiliation}"
    end
  end

  describe "#latest_version" do
    before do
      # create a bunch of old minor versions
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 1)
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 2)
      FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 3)
    end

    it "returns the latest version" do
      versioned_text = FactoryGirl.create(:versioned_text, paper: paper, major_version: 1, minor_version: 0)
      expect(paper.latest_version).to eq(versioned_text)
    end
  end

  describe "#download_body" do
    let(:doc) { Nokogiri::HTML(paper.download_body) }
    after do
      expect(doc.errors).to be_empty
    end

    it "returns paper body in HTML for export" do
      with_aws_cassette 'supporting_info_files_controller' do
        paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/yeti.tiff')
      end

      expect(doc.search('h2:contains("Supporting Information")').length).to eq(1)
    end

    it "does not have supporting information section without supporting information" do
      expect(paper.supporting_information_files.count).to eq(0)

      expect(doc.search('h2:contains("Supporting Information")').length).to eq(0)
    end

    it "has image preview and link with image" do
      with_aws_cassette 'supporting_info_files_controller' do
        paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/yeti.tiff')
      end

      expect(doc.search('a:contains("yeti.tiff")').length).to eq(1)
      expect(doc.search('img[src*="yeti.png"]').length).to eq(1)
    end

    it "has link to unsupported image attachment" do
      with_aws_cassette 'supporting_info_files_controller_not_supported_image' do
        paper.supporting_information_files.create! attachment: ::File.open('spec/fixtures/cat.bmp')
      end

      expect(doc.search('img').length).to eq(0)
      expect(doc.search('a:contains("cat.bmp")').length).to eq(1)
      expect(doc.search('a[href*="cat.bmp"]').length).to eq(1)
    end
  end

  describe "#resubmitted?" do
    let(:paper) { FactoryGirl.create(:paper) }

    context "with pending decisions" do
      before do
        paper.decisions.first.update!(verdict: nil)
      end

      specify { expect(paper.resubmitted?).to eq(true) }
    end

    context "with non-pending decisions" do
      before do
        paper.decisions.first.update!(verdict: "accept")
      end

      specify { expect(paper.resubmitted?).to eq(false) }
    end

    context "with no decisions" do
      before do
        paper.decisions.destroy_all
      end

      specify { expect(paper.resubmitted?).to eq(false) }
    end

  end
end
