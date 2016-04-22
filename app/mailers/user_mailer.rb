class UserMailer < ActionMailer::Base
  include MailerHelper
  add_template_helper ClientRouteHelper
  add_template_helper TemplateHelper
  default from: Rails.configuration.from_email
  layout "mailer"

  after_action :prevent_delivery_to_invalid_recipient

  def add_collaborator(invitor_id, invitee_id, paper_id)
    @paper = Paper.find(paper_id)
    invitor = User.find_by(id: invitor_id)
    invitee = User.find_by(id: invitee_id)
    @invitor_name = display_name(invitor)
    @invitee_name = display_name(invitee)
    @journal = @paper.journal

    mail(
      to: invitee.try(:email),
      subject: "You've been added as a collaborator to the manuscript, \"#{@paper.display_title}\"")
  end

  def add_participant(assigner_id, assignee_id, task_id)
    @task = Task.find(task_id)
    @paper = @task.paper
    @journal = @paper.journal
    assigner = User.find_by(id: assigner_id)
    assignee = User.find_by(id: assignee_id)
    @assigner_name = display_name(assigner)
    @assignee_name = display_name(assignee)

    mail(
      to: assignee.try(:email),
      subject: "You've been added to a conversation on the manuscript, \"#{@paper.display_title}\"")
  end

  def add_editor_to_editors_discussion(invitee_id, task_id)
    @task = Task.find task_id
    invitee = User.find invitee_id
    @invitee_name = display_name(invitee)
    @paper = @task.paper

    mail(
      to: invitee.email,
      subject: "You've been invited to the editor discussion for the manuscript, \"#{@paper.display_title}\"")
  end

  def assigned_editor(editor_id, paper_id)
    @paper = Paper.find(paper_id)
    user = User.find(editor_id)
    @editor_name = display_name(user)
    @journal = @paper.journal

    mail(
      to: user.try(:email),
      subject: "You've been assigned as an editor for the manuscript, \"#{@paper.display_title}\"")
  end

  def mention_collaborator(comment_id, commentee_id)
    @comment = Comment.find(comment_id)
    @commenter = @comment.commenter
    @commentee = User.find(commentee_id)
    @task = @comment.task
    @paper = @task.paper
    @journal = @paper.journal

    mail(
      to: @commentee.try(:email),
      subject: "You've been mentioned on the manuscript, #{app_name}")
  end

  def notify_creator_of_paper_submission(paper_id)
    @paper = Paper.find(paper_id)
    @author = @paper.creator
    @journal = @paper.journal

    mail(
      to: @author.try(:email),
      subject: "Thank you for submitting your manuscript to PLOS #{app_name}")
  end

  def notify_admin_of_paper_submission(paper_id, user_id)
    @paper = Paper.find paper_id
    @journal = @paper.journal
    @admin = User.find user_id

    mail(
      to: @admin.email,
      subject: "New manuscript submitted to PLOS #{@journal.name}: \"#{@paper.display_title}\"")
  end

  def notify_mention_in_discussion(user_id, topic_id, reply_id = nil)
    @user = User.find(user_id)
    @reply = DiscussionReply.find(reply_id) if reply_id
    @topic = DiscussionTopic.find(topic_id)
    @paper = Paper.find(@topic.paper.id)

    mail(
      to: @user.email,
      subject: "You've been mentioned on the manuscript, \"#{@paper.title}\"")
  end

  def notify_added_to_topic(user_id, topic_id)
    @user = User.find(user_id)
    @topic = DiscussionTopic.find(topic_id)
    @paper = Paper.find(@topic.paper.id)

    mail(
      to: @user.email,
      subject: "You've been added to a conversation on the manuscript," \
        "\"#{@paper.title}\"")
  end
end
