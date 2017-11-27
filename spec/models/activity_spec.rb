# Disabling line length for english text, block delimiters for
# "it { is_expected" blocks
# rubocop:disable Metrics/LineLength, Style/BlockDelimiters
require 'rails_helper'

describe Activity do
  let(:user) { FactoryGirl.build_stubbed(:user) }

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

  describe "#assignment_removed!" do
    subject(:activity) { Activity.assignment_removed!(assignment, user: user) }
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
        activity_key: "assignment.removed",
        subject: assignment.assigned_to,
        user: user,
        message: "#{user.full_name} was removed as #{role.name}"
    end
  end

  describe "#author_added!" do
    subject(:activity) { Activity.author_added!(author, user: user) }
    let(:author) { FactoryGirl.build_stubbed(:author) }

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "author.created",
        subject: author.paper,
        user: user,
        message: "Added Author"
    )}
  end

  describe "#co_author_confirmed!" do
    subject(:activity) { Activity.co_author_confirmed!(author, user: user) }
    let(:author) do
      FactoryGirl.build_stubbed(:author,
        first_name: "Arthur",
        last_name: "Author"
      )
    end

    it {
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "author.co_author_confirmed",
        subject: author.paper,
        user: user,
        message: "Arthur Author confirmed authorship"
    )}
  end

  describe "#task_sent_to_author!" do
    subject(:activity) { Activity.task_sent_to_author!(task, user: user) }
    let(:task) { FactoryGirl.build_stubbed(:assign_team_task) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "task.sent_to_author",
        subject: task.paper,
        user: user,
        message: "Assign Team sent to author"
    )}
  end

  describe "#tech_check_fixed!" do
    subject(:activity) { Activity.tech_check_fixed!(paper, user: user) }
    let(:paper) { FactoryGirl.build_stubbed(:changes_for_author_task) }

    it {
      is_expected.to have_attributes(
        feed_name: 'manuscript',
        activity_key: 'paper.tech_fixed',
        subject: paper,
        user: user,
        message: 'Author tech fixes were submitted'
    )}
  end

  describe "#comment_created" do
    subject(:activity) { Activity.comment_created!(comment, user: user) }
    let(:comment){ FactoryGirl.build_stubbed(:comment) }

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
    let(:decision) { FactoryGirl.build_stubbed(:decision) }

    it do
      is_expected.to have_attributes(
        feed_name: "manuscript",
        activity_key: "decision.made",
        subject: decision.paper,
        user: user,
        message: "A decision was made: #{decision.verdict.titleize}"
      )
    end
  end

  describe "#decision_rescinded!" do
    subject(:activities) { Activity.decision_rescinded!(decision, user: user) }
    let(:decision) { FactoryGirl.build_stubbed(:decision) }

    it do
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "decision.rescinded",
        subject: decision.paper,
        user: user,
        message: "A decision was rescinded"
      )
    end
  end

  describe "#invitation_sent!" do
    subject(:activity) { Activity.invitation_sent!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build_stubbed(:invitation) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "invitation.sent",
        subject: invitation.paper,
        user: user,
        message: "#{invitation.recipient_name} was invited as #{invitation.invitee_role.capitalize}"
    )}
  end

  describe "#invitation_accepted!" do
    subject(:activity) { Activity.invitation_accepted!(invitation, user: activity_user) }
    let(:invitation) { FactoryGirl.build_stubbed(:invitation) }

    context 'accepted by invitee' do
      let(:activity_user) { invitation.invitee }
      it {
        is_expected.to have_attributes(
          feed_name: "workflow",
          activity_key: "invitation.accepted",
          subject: invitation.paper,
          user: activity_user,
          message: "#{invitation.recipient_name} accepted invitation as #{invitation.invitee_role.capitalize}"
        )
      }
    end

    context 'accepted by different user' do
      let(:activity_user) { invitation.actor }
      it {
        is_expected.to have_attributes(
          feed_name: "workflow",
          activity_key: "invitation.accepted",
          subject: invitation.paper,
          user: activity_user,
          message: "#{activity_user.full_name} accepted invitation as #{invitation.invitee_role.capitalize} on behalf of #{invitation.recipient_name}"
        )
      }
    end
  end

  describe "#invitation_declined!" do
    subject(:activity) { Activity.invitation_declined!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build_stubbed(:invitation) }

    it {
      is_expected.to have_attributes(
        feed_name: "workflow",
        activity_key: "invitation.declined",
        subject: invitation.paper,
        user: user,
        message: "#{invitation.recipient_name} declined invitation as #{invitation.invitee_role.capitalize}"
    )}
  end

  describe "#invitation_withdrawn!" do
    subject(:activity) { Activity.invitation_withdrawn!(invitation, user: user) }
    let(:invitation) { FactoryGirl.build_stubbed(:invitation) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

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
    let(:participation) { FactoryGirl.build_stubbed(:assignment, :assigned_to_task) }

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
    let(:participation) { FactoryGirl.build_stubbed(:assignment, :assigned_to_task) }

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
      subject(:activity) { Activity.task_updated!(task, user: user, last_assigned_user: nil) }
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

      context 'User assignment is never done' do
        let!(:task) { FactoryGirl.create(:metadata_task) }
        it 'Does not log any event' do
          expect { Activity.task_updated!(task, user: user, last_assigned_user: nil) }.not_to change { Activity.count }
        end
      end

      context 'An user is assigned to a task for the first time' do
        let!(:task) { FactoryGirl.create(:metadata_task, assigned_user: assigned_user) }
        let(:assigned_user) { FactoryGirl.create(:user) }
        let!(:activity) { Activity.task_updated!(task, user: user, last_assigned_user: nil) }
        it 'logs an user assignment event' do
          expect(Activity.last).to have_attributes(
            feed_name: "workflow",
            activity_key: "task.user_assigned",
            subject: task.paper,
            user_id: user.id,
            message: "#{user.full_name} assigned #{assigned_user.full_name} to task #{task.title}"
          )
        end
      end

      context 'Assigned user is going to be removed from the task' do
        let!(:task) { FactoryGirl.create(:metadata_task, assigned_user: nil) }
        let(:last_assigned_user) { FactoryGirl.build_stubbed(:user) }
        let!(:activity) { Activity.task_updated!(task, user: user, last_assigned_user: last_assigned_user) }

        it 'logs an user revoking event' do
          expect(Activity.last).to have_attributes(
            feed_name: "workflow",
            activity_key: "task.assigned_user_removed",
            subject: task.paper,
            user_id: user.id,
            message: "#{user.full_name} removed assigned user #{last_assigned_user.full_name} from task #{task.title}"
          )
        end
      end
    end

    context "a submission task" do
      subject(:activity) { Activity.task_updated!(task, user: user, last_assigned_user: nil) }
      let(:task) { FactoryGirl.create(:ad_hoc_task) }

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

  describe '#correspondence_created!' do
    let(:correspondence) { FactoryGirl.create :correspondence }
    subject { Activity.correspondence_created!(correspondence, user: user) }

    it {
      is_expected.to have_attributes(
        feed_name: 'workflow',
        activity_key: 'correspondence.created',
        subject: correspondence
      )
    }
  end

  describe '#correspondence_edited!' do
    let(:correspondence) { FactoryGirl.create :correspondence }
    subject { Activity.correspondence_edited!(correspondence, user: user) }

    it {
      is_expected.to have_attributes(
        feed_name: 'workflow',
        activity_key: 'correspondence.edited',
        subject: correspondence
      )
    }
  end
end
