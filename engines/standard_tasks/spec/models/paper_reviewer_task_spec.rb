require 'rails_helper'

describe StandardTasks::PaperReviewerTask do
  let!(:journal) do
    journal = create :journal
    journal.manuscript_manager_templates.destroy_all
    mmt = create :manuscript_manager_template, journal: journal
    mmt.phase_templates.create! name: "Collect Info"
    mmt.phase_templates.create! name: "Get Reviews"
    journal
  end

  let(:paper) { create :paper, :with_tasks, journal: journal }
  let(:phase) { paper.phases.first }

  let(:albert) { create :user, :site_admin }
  let(:neil) { create :user }
  let!(:task) do
    StandardTasks::PaperReviewerTask.create!({
      phase: paper.phases.first,
      title: "Invite Reviewers",
      role: "admin"
    })
  end

  describe '#invitation_invited' do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it 'notifies the invited reviewer' do
      expect {task.invitation_invited invitation}.to change {
        Sidekiq::Extensions::DelayedMailer.jobs.length
      }.by 1
    end
  end

  describe '#invitation_accepted' do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it 'adds the reviewer to the list of reviewers' do
      expect(paper.reviewers.count).to eq 0
      invitation.accept!
      expect(paper.reviewers.count).to eq 1
      expect(paper.reload.reviewers).to include invitation.invitee
    end

  end

  describe "#reviewer_ids=" do
    let(:task) { StandardTasks::PaperReviewerTask.create!(phase: paper.phases.first, title: "Assign Reviewers", role: "editor") }

    it "creates reviewer paper roles only for new ids" do
      create(:paper_role, :reviewer, paper: paper, user: albert)
      task.reviewer_ids = [neil.id.to_s]
      expect(PaperRole.reviewers.where(paper: paper, user: neil)).not_to be_empty
    end

    it "creates reviewer report tasks only for new ids" do
      task.reviewer_ids = [neil.id.to_s]
      phase = paper.phases.where(name: 'Get Reviews').first
      expect(StandardTasks::ReviewerReportTask.where(phase: phase)).to be_present
    end

    it "puts the reviewer's name into the task's title" do
      task.reviewer_ids = [neil.id.to_s]
      phase = paper.phases.where(name: 'Get Reviews').first
      new_task = StandardTasks::ReviewerReportTask.find_by(phase: phase)

      expect(new_task.title).to eq("Review by #{neil.full_name}")
    end

    it "sends an 'add reviewer' notification to the user" do
      mailer = double(UserMailer).as_null_object
      allow(UserMailer).to receive(:delay).and_return(mailer)
      task.reviewer_ids = [neil.id.to_s]

      expect(mailer).to have_received(:add_reviewer)
    end

    it "deletes paper roles not present in the specified user_id" do
      create(:paper_role, :reviewer, paper: paper, user: albert)
      task.reviewer_ids = [neil.id.to_s]
      expect(PaperRole.reviewers.where(paper: paper, user: albert)).to be_empty
    end

    context "when the 'Get Reviews' phase isn't present" do
      before do
        paper.phases.where(name: "Get Reviews").first.destroy!
      end

      context "and the phase is of the assign reviewer's phase" do
        it "associates the ReviewerReport task from that phase" do
          task.reviewer_ids = [neil.id.to_s]
          expect(StandardTasks::ReviewerReportTask.where(phase: task.phase)).to be_present
        end
      end
    end
  end
end
