class UserMailer < ActionMailer::Base
  include MailerHelper
  add_template_helper ClientRouteHelper
  default from: ENV.fetch('FROM_EMAIL')
  layout "mailer"

  after_action :prevent_delivery_to_invalid_recipient

  def add_collaborator(invitor_id, invitee_id, paper_id)
    @paper = Paper.find(paper_id)
    invitor = User.find_by(id: invitor_id)
    invitee = User.find_by(id: invitee_id)
    @invitor_name = display_name(invitor)
    @invitee_name = display_name(invitee)

    mail(
      to: invitee.try(:email),
      subject: "You've been added as a collaborator to a paper on Tahi")
  end

  def add_participant(assigner_id, assignee_id, task_id)
    @task = Task.find(task_id)
    assigner = User.find_by(id: assigner_id)
    assignee = User.find_by(id: assignee_id)
    @assigner_name = display_name(assigner)
    @assignee_name = display_name(assignee)

    mail(
      to: assignee.try(:email),
      subject: "You've been added to a conversation on Tahi")
  end

  def add_reviewer(reviewer_id, paper_id)
    @paper = Paper.find(paper_id)
    user = User.find(reviewer_id)
    @reviewer_name = display_name(user)

    mail(
      to: user.try(:email),
      subject: "You've been added as a reviewer on Tahi")
  end

  def assigned_editor(editor_id, paper_id)
    @paper = Paper.find(paper_id)
    user = User.find(editor_id)
    @editor_name = display_name(user)

    mail(
      to: user.try(:email),
      subject: "You've been assigned as an editor on Tahi")
  end

  def notify_editor_of_paper_resubmission(paper_id)
    @paper = Paper.find(paper_id)
    @editor = @paper.editor
    @author = @paper.creator

    mail(
      to: @editor.email,
      subject: "Manuscript has been resubmitted in Tahi")
  end

  def mention_collaborator(comment_id, commentee_id)
    @comment = Comment.find(comment_id)
    @commenter = @comment.commenter
    @commentee = User.find(commentee_id)
    @task = @comment.task
    @paper = @task.paper

    mail(
      to: @commentee.try(:email),
      subject: "You've been mentioned on Tahi")
  end

  def paper_submission(paper_id)
    @paper = Paper.find(paper_id)
    @author = @paper.creator

    mail(
      to: @author.try(:email),
      subject: "Thank You for submitting a Manuscript on Tahi")
  end

  def notify_admin_of_paper_submission(paper_id, user_id)
    @paper = Paper.find paper_id
    @journal = @paper.journal
    @admin = User.find user_id

    mail(
      to: @admin.email,
      subject: "Manuscript #{@paper.title} has been submitted on Tahi")
  end
end
