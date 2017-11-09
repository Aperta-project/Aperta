# An Activity represents an event or action that has taken place in the system.
# Activities are used to make up a feed for various users in the system. The
# feed is determined by the feed name assigned to each activity.
class Activity < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
  belongs_to :user

  scope :updated_within_the_last, -> (time) { where("updated_at >= ?", time.ago) }

  scope :feed_for, -> (feed_names, subject) do
    where(feed_name: feed_names, subject: subject).order('created_at DESC')
  end

  def self.assignment_created!(assignment, user:)
    msg = "#{assignment.user.full_name} was added as #{assignment.role.name}"
    create(
      feed_name: "workflow",
      activity_key: "assignment.created",
      subject: assignment.assigned_to,
      user: user,
      message: msg
    )
  end

  def self.assignment_removed!(assignment, user:)
    msg = "#{assignment.user.full_name} was removed as #{assignment.role.name}"
    create(
      feed_name: "workflow",
      activity_key: "assignment.removed",
      subject: assignment.assigned_to,
      user: user,
      message: msg
    )
  end

  def self.author_added!(author, user:)
    create(
      feed_name: "manuscript",
      activity_key: "author.created",
      subject: author.paper,
      user: user,
      message: "Added Author"
    )
  end

  def self.co_author_confirmed!(co_author, user:)
    create(
      feed_name: "manuscript",
      activity_key: "author.co_author_confirmed",
      subject: co_author.paper,
      user: user,
      message: "#{co_author.full_name} confirmed authorship"
    )
  end

  def self.collaborator_added!(collaboration_assignment, user:)
    msg = [
      collaboration_assignment.user.full_name,
      'has been assigned as collaborator'
    ].join(' ')

    create(
      feed_name: 'manuscript',
      activity_key: 'collaborator.added',
      subject: collaboration_assignment.assigned_to,
      user: user,
      message: msg
    )
  end

  def self.collaborator_removed!(collaboration_assignment, user:)
    msg = [
      collaboration_assignment.user.full_name,
      'has been removed as collaborator'
    ].join(' ')
    create(
      feed_name: 'manuscript',
      activity_key: 'collaborator.removed',
      subject: collaboration_assignment.assigned_to,
      user: user,
      message: msg
    )
  end

  def self.task_sent_to_author!(task, user:)
    create(
      feed_name: "workflow",
      activity_key: "task.sent_to_author",
      subject: task.paper,
      user: user,
      message: "#{task.title} sent to author"
    )
  end

  def self.comment_created!(comment, user:)
    create(
      feed_name: "workflow",
      activity_key: "commented.created",
      subject: comment.paper,
      user: user,
      message: "A comment was added to #{comment.task.title} card"
    )
  end

  def self.decision_made!(decision, user:)
    create(
      feed_name: "manuscript",
      activity_key: "decision.made",
      subject: decision.paper,
      user: user,
      message: "A decision was made: #{decision.verdict.titleize}"
    )
  end

  def self.decision_rescinded!(decision, user:)
    create(
      feed_name: "workflow",
      activity_key: "decision.rescinded",
      subject: decision.paper,
      user: user,
      message: "A decision was rescinded"
    )
  end

  def self.invitation_sent!(invitation, user:)
    create(
      feed_name: "workflow",
      activity_key: "invitation.sent",
      subject: invitation.paper,
      user: user,
      message: "#{invitation.recipient_name} was invited as #{invitation.invitee_role.capitalize}"
    )
  end

  def self.invitation_accepted!(invitation, user:)
    message = if user == invitation.invitee
                "#{invitation.recipient_name} accepted invitation as #{invitation.invitee_role.capitalize}"
              else
                "#{user.username} accepted invitation as #{invitation.invitee_role.capitalize} on behalf of #{invitation.recipient_name}"
              end
    create(
      feed_name: "workflow",
      activity_key: "invitation.accepted",
      subject: invitation.paper,
      user: user,
      message: message
    )
  end

  def self.invitation_declined!(invitation, user:)
    create(
      feed_name: "workflow",
      activity_key: "invitation.declined",
      subject: invitation.paper,
      user: user,
      message: "#{invitation.recipient_name} declined invitation as #{invitation.invitee_role.capitalize}"
    )
  end

  def self.invitation_withdrawn!(invitation, user:)
    role = invitation.invitee_role.capitalize
    invitee = invitation.recipient_name
    create(
      feed_name: "workflow",
      activity_key: "invitation.withdrawn",
      subject: invitation.paper,
      user: user,
      message: "#{invitee}'s invitation as #{role} was withdrawn"
    )
  end

  def self.paper_created!(paper, user:)
    create(
      feed_name: "manuscript",
      activity_key: "paper.created",
      subject: paper,
      user: user,
      message: "Manuscript was created"
    )
  end

  def self.paper_edited!(paper, user:)
    activities = where(activity_key: "paper.edited", user: user, subject: paper)
    activity = activities.updated_within_the_last(10.minutes).first

    if activity
      activity.touch
    else
      create(
        feed_name: "manuscript",
        activity_key: "paper.edited",
        subject: paper,
        user: user,
        message: "Manuscript was edited"
      )
    end
  end

  def self.paper_submitted!(paper, user:)
    create(
      feed_name: "manuscript",
      activity_key: "paper.submitted",
      subject: paper,
      user: user,
      message: "Manuscript was submitted"
    )
  end

  def self.paper_initially_submitted!(paper, user:)
    create(
      feed_name: "manuscript",
      activity_key: "paper.initially_submitted",
      subject: paper,
      user: user,
      message: "Manuscript was initially submitted"
    )
  end

  def self.paper_withdrawn!(paper, user:)
    create(
      feed_name: "workflow",
      activity_key: "paper.withdrawn",
      subject: paper,
      user: user,
      message: "Manuscript was withdrawn"
    )
  end

  def self.paper_reactivated!(paper, user:)
    create(
      feed_name: "workflow",
      activity_key: "paper.reactivated",
      subject: paper,
      user: user,
      message: "Manuscript was reactivated"
    )
  end

  def self.participation_created!(participation, user:)
    create(
      feed_name: "workflow",
      activity_key: "participation.created",
      subject: participation.assigned_to.paper,
      user: user,
      message: "Added Contributor: #{participation.user.full_name}"
    )
  end

  def self.participation_destroyed!(participation, user:)
    create(
      feed_name: "workflow",
      activity_key: "particpation.destroyed",
      subject: participation.assigned_to.paper,
      user: user,
      message: "Removed Contributor: #{participation.user.full_name}"
    )
  end

  def self.editable_toggled!(paper, user:)
    create(
      feed_name: 'workflow',
      activity_key: 'paper.editable_toggled',
      subject: paper,
      user: user,
      message: "Editability was set to #{paper.editable?}"
    )
  end

  def self.task_updated!(task, user:, last_assigned_user:)
    feed_name = task.submission_task? ? 'manuscript' : 'workflow'
    activity = new(feed_name: feed_name, subject: task.paper, user: user)
    if task.newly_complete?
      activity.update!(
        activity_key: "task.completed",
        message: "#{task.title} card was marked as complete"
      )
    elsif task.newly_incomplete?
      activity.update!(
        activity_key: "task.incompleted",
        message: "#{task.title} card was marked as incomplete"
      )
    end
    user_assigned_to_task(task, user: user, last_assigned_user: last_assigned_user)
    activity
  end

  def self.tech_check_fixed!(paper, user:)
    create(
      feed_name: 'manuscript',
      activity_key: 'paper.tech_fixed',
      subject: paper,
      user: user,
      message: 'Author tech fixes were submitted'
    )
  end

  def self.state_changed!(paper, to:)
    create(
      feed_name: 'forensic',
      activity_key: "paper.state_changed.#{to}",
      subject: paper,
      message: "Paper state changed to #{to}"
    )
  end

  def self.reminder_sent!(reminder)
    task_klass = reminder.due_datetime.due.class.name
    task_id = reminder.due_datetime.due.id
    create(
      feed_name: 'workflow',
      activity_key: 'reminder.sent',
      subject: reminder.due_datetime.due.paper,
      message: "#{reminder.name} was sent for #{task_klass}[#{task_id}]"
    )
  end

  private_class_method

  def self.user_assigned_to_task(task, user:, last_assigned_user:)
    assigned_user = task.assigned_user || last_assigned_user
    return unless assigned_user # if user was never assigned to the task don't log any event
    if task.assigned_user
      user_assigned_to_task_created!(task, user: user, assigned_user: assigned_user)
    else
      user_assigned_to_task_removed!(task, user: user, assigned_user: last_assigned_user)
    end
  end

  def self.user_assigned_to_task_created!(task, user:, assigned_user:)
    msg = "#{user.full_name} assigned #{assigned_user.full_name} to task #{task.title}"
    create(
      feed_name: "workflow",
      activity_key: "task.user_assigned",
      subject: task.paper,
      user: user,
      message: msg
    )
  end

  def self.user_assigned_to_task_removed!(task, user:, assigned_user:)
    msg = "#{user.full_name} removed assigned user #{assigned_user.full_name} from task #{task.title}"
    create(
      feed_name: "workflow",
      activity_key: "task.assigned_user_removed",
      subject: task.paper,
      user: user,
      message: msg
    )
  end

  def self.correspondence_created!(correspondence, user:)
    date = DateTime.now.utc.strftime('%B %d %Y, %H:%M')
    create(
      feed_name: 'workflow',
      activity_key: 'correspondence.created',
      subject: correspondence,
      user: user,
      message: "Added by #{user.full_name} on #{date}"
    )
  end
end
