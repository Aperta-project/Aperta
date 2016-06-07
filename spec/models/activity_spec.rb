# Disabling line length for english text, block delimiters for
# "it { is_expected" blocks
# rubocop:disable Metrics/LineLength, Style/BlockDelimiters
require 'rails_helper'

describe Activity do
  let(:user) { FactoryGirl.build(:user) }

  describe "#assignment_created!" do
    subject(:activity) { Activity.assignment_created!(assignment, user: user) }
    let(:assignment) do
      FactoryGirl.build_stubbed(
        :assignment,
        assigned_to: paper,
        role: role,
        user: user
      )
    end
    let(:paper) { FactoryGirl.build_stubbed(:paper) }
    let(:role) { FactoryGirl.build_stubbed(:role, name: "Super") }

    it do
      is_expected.to have_attributes \
        feed_name: "workflow",
        activity_key: "assignment.created",
        subject: assignment.assigned_to,
        user: user,
        message: "#{user.full_name} was added as #{role.name}"
    end
  end

  describe "#author_added!" do
    subject(:activity) { Activity.author_added!(author, user: user) }
    let(:author) { FactoryGirl.build(:author) }

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "author.created",
        subject: author.paper,
        user: user,
        message: "Added Author"
    )}
  end

  describe "#task_sent_to_author!" do
    subject(:activity) { Activity.task_sent_to_author!(task, user: user) }
    let(:task) { FactoryGirl.build(:assign_team_task) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "task.sent_to_author",
        subject: task.paper,
        user: user,
        message: "Assign Team sent to author"
    )}
  end

  describe "#comment_created" do
    subject(:activity) { Activity.comment_created!(comment, user: user) }
    let(:comment){ FactoryGirl.build(:comment) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "commented.created",
        subject: comment.paper,
        user: user,
        message: "A comment was added to #{comment.task.title} card"
    )}
  end

  describe "#decision_made!" do
    subject(:activity) { Activity.decision_made!(decision, user: user) }
    let(:decision) { FactoryGirl.build(:decision) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "decision.made",
        subject: decision.paper,
        user: user,
        message: "#{decision.verdict.titleize} was sent to author"
      )}
  end

  describe "#invitation_created!" do
    subject(:activity) { Activity.invitation_created!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build(:invitation) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "invitation.created",
        subject: invitation.paper,
        user: user,
        message: "#{invitation.recipient_name} was invited as #{invitation.invitee_role.capitalize}"
    )}
  end

  describe "#invitation_accepted!" do
    subject(:activity) { Activity.invitation_accepted!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build(:invitation) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "invitation.accepted",
        subject: invitation.paper,
        user: user,
        message: "#{invitation.recipient_name} accepted invitation as #{invitation.invitee_role.capitalize}"
    )}
  end

  describe "#invitation_rejected!" do
    subject(:activity) { Activity.invitation_rejected!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build(:invitation) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "invitation.rejected",
        subject: invitation.paper,
        user: user,
        message: "#{invitation.recipient_name} declined invitation as #{invitation.invitee_role.capitalize}"
    )}
  end

  describe "#invitation_withdrawn!" do
    subject(:activity) { Activity.invitation_withdrawn!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build(:invitation) }

    let(:role) { invitation.invitee_role.capitalize }
    let(:invitee) { invitation.recipient_name }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "invitation.withdrawn",
        subject: invitation.paper,
        user: user,
        message: "#{invitee}'s invitation as #{role} was withdrawn"
      )
    }
  end

  describe "#paper_created!" do
    subject(:activity) { Activity.paper_created!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "paper.created",
        subject: paper,
        user: user,
        message: "Manuscript was created"
    )}
  end

  describe "#paper_edited!" do
    subject(:activity) { Activity.paper_edited!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "paper.edited",
        subject: paper,
        user: user,
        message: "Manuscript was edited"
    )}

    context "and the paper has been edited within the past 10 minutes" do
      it "updates the existing activity for the user" do
        activity = Activity.paper_edited!(paper, user: user)

        Timecop.freeze do
          activity.update! updated_at: 10.minutes.ago

          expect {
            Activity.paper_edited!(paper, user: user)
          }.to_not change(Activity, :count)

          activity.reload
          expect(activity.updated_at.utc).to be_within(1.second).of(Time.now.utc)
        end
      end
    end

    context "and the paper has been edited outside of the last 10 minutes" do
      it "creates a new activity for the user" do
        activity = Activity.paper_edited!(paper, user: user)

        Timecop.freeze do
          activity.update! updated_at: 11.minutes.ago

          expect {
            Activity.paper_edited!(paper, user: user)
          }.to change(Activity, :count).by(1)

          expect(Activity.last).to_not eq(activity.reload)
        end
      end
    end
  end

  describe "#paper_created!" do
    subject(:activity) { Activity.paper_created!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "paper.created",
        subject: paper,
        user: user,
        message: "Manuscript was created"
    )}
  end


  describe "#paper_reactivated!" do
    subject(:activity) { Activity.paper_reactivated!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "paper.reactivated",
        subject: paper,
        user: user,
        message: "Manuscript was reactivated"
    )}
  end

  describe "#paper_withdrawn!" do
    subject(:activity) { Activity.paper_withdrawn!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "paper.withdrawn",
        subject: paper,
        user: user,
        message: "Manuscript was withdrawn"
    )}
  end

  describe '#collaborator_added!' do
    subject(:activity) do
      Activity.collaborator_added!(collaboration, user: user)
    end
    let!(:paper) { FactoryGirl.build_stubbed(:paper) }
    let!(:collaboration) do
       FactoryGirl.build_stubbed(
        :assignment,
        assigned_to: paper,
        user: FactoryGirl.build_stubbed(:user)
      )
    end

    it do
      is_expected.to have_attributes(
        feed_name: 'manuscript',
        activity_key: 'collaborator.added',
        subject: paper,
        user: user,
        message: "#{collaboration.user.full_name} has been assigned as collaborator"
      )
    end
  end

  describe '#collaborator_removed!' do
    subject(:activity) do
      Activity.collaborator_removed!(collaboration, user: user)
    end
    let!(:paper) { FactoryGirl.build_stubbed(:paper) }
    let!(:collaboration) do
       FactoryGirl.build_stubbed(
        :assignment,
        assigned_to: paper,
        user: FactoryGirl.build_stubbed(:user)
      )
    end

    it do
      is_expected.to have_attributes(
        feed_name: 'manuscript',
        activity_key: 'collaborator.removed',
        subject: paper,
        user: user,
        message: "#{collaboration.user.full_name} has been removed as collaborator"
      )
    end
  end

  describe "#paper_submitted!" do
    subject(:activity) { Activity.paper_submitted!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "paper.submitted",
        subject: paper,
        user: user,
        message: "Manuscript was submitted"
    )}
  end

  describe "#paper_initially_submitted!" do
    subject(:activity) { Activity.paper_initially_submitted!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it do
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "paper.initially_submitted",
        subject: paper,
        user: user,
        message: "Manuscript was initially submitted")
    end
  end

  describe '#editability_toggled!' do
    subject(:activity) { Activity.editable_toggled!(paper, user: user) }
    let(:paper) { FactoryGirl.build(:paper) }

    it 'adds a workflow activity when editability is toggled' do
      is_expected.to have_attributes(
        feed_name: 'workflow',
        activity_key: 'paper.editable_toggled',
        subject: paper,
        user: user,
        message: "Editability was set to #{paper.editable?}"
      )
    end
  end

  describe "#participation_created!" do
    subject(:activity) { Activity.participation_created!(participation, user: user) }
    let(:participation) { FactoryGirl.build(:assignment, :assigned_to_task) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "participation.created",
        subject: participation.assigned_to.paper,
        user: user,
        message: "Added Contributor: #{participation.user.full_name}"
    )}
  end

  describe "#participation_destroyed!" do
    subject(:activity) { Activity.participation_destroyed!(participation, user: user) }
    let(:participation) { FactoryGirl.build(:assignment, :assigned_to_task) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "particpation.destroyed",
        subject: participation.assigned_to.paper,
        user: user,
        message: "Removed Contributor: #{participation.user.full_name}"
    )}
  end

  describe "#task_updated!" do
    context "a submission task" do
      subject(:activity) { Activity.task_updated!(task, user: user) }
      let(:task) { FactoryGirl.create(:metadata_task) }

      context "was completed" do
        before { task.update! completed: true }

        it {
          is_expected.to have_attributes(
            feed_name: "manuscript",
            activity_key: "task.completed",
            subject: task.paper,
            user: user,
            message: "#{task.title} card was marked as complete"
        )}
      end

      context "was incompleted" do
        before {
          task.update! completed: true
          task.update! completed: false
        }

        it {
          is_expected.to have_attributes(
            feed_name: "manuscript",
            activity_key: "task.incompleted",
            subject: task.paper,
            user: user,
            message: "#{task.title} card was marked as incomplete"
        )}
      end
    end

    context "a submission task" do
      subject(:activity) { Activity.task_updated!(task, user: user) }
      let(:task) { FactoryGirl.create(:task) }

      context "was completed" do
        before { task.update! completed: true }

        it {
          is_expected.to have_attributes(
            feed_name: "workflow",
            activity_key: "task.completed",
            subject: task.paper,
            user: user,
            message: "#{task.title} card was marked as complete"
        )}
      end

      context "was incompleted" do
        before {
          task.update! completed: true
          task.update! completed: false
        }

        it {
          is_expected.to have_attributes(
            feed_name: "workflow",
            activity_key: "task.incompleted",
            subject: task.paper,
            user: user,
            message: "#{task.title} card was marked as incomplete"
        )}
      end
    end
  end
end
