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

  def self.author_added!(author, user:)
    create(
      feed_name: "manuscript",
      activity_key: "author.created",
      subject: author.paper,
      user: user,
      message: "Added Author"
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
      feed_name: "workflow",
      activity_key: "decision.made",
      subject: decision.paper,
      user: user,
      message: "#{decision.verdict.titleize} was sent to author"
    )
  end

  def self.invitation_created!(invitation, user:)
    create(
      feed_name: "workflow",
      activity_key: "invitation.created",
      subject: invitation.paper,
      user: user,
      message: "#{invitation.recipient_name} was invited as #{invitation.task.invitee_role.capitalize}"
    )
  end

  def self.invitation_accepted!(invitation, user:)
    create(
      feed_name: "workflow",
      activity_key: "invitation.accepted",
      subject: invitation.paper,
      user: user,
      message: "#{invitation.recipient_name} accepted invitation as #{invitation.task.invitee_role.capitalize}"
    )
  end

  def self.invitation_rejected!(invitation, user:)
    create(
      feed_name: "workflow",
      activity_key: "invitation.rejected",
      subject: invitation.paper,
      user: user,
      message: "#{invitation.recipient_name} declined invitation as #{invitation.task.invitee_role.capitalize}"
    )
  end

  def self.invitation_withdrawn!(invitation, user:)
    role = invitation.task.invitee_role.capitalize
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

  def self.task_updated!(task, user:)
    activity = new(feed_name: task.activity_feed_name,
                   subject: task.paper,
                   user: user)
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
    activity
  end
end
