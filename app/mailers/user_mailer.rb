class UserMailer < ActionMailer::Base
  include MailerHelper
  default from: ENV.fetch('FROM_EMAIL')

  def add_collaborator(invitor_id, invitee_id, paper_id)
    @paper = Paper.find(paper_id)
    invitor = User.find(invitor_id)
    invitee = User.find(invitee_id)
    @invitor_name = display_name(invitor)
    @invitee_name = display_name(invitee)

    mail(
      to: invitee.email,
      subject: "You've been added as a collaborator to a paper on Tahi")
  end

  def assign_task(invitor_id, invitee_id, task_id)
    @task = Task.find(task_id)
    invitor = User.find(invitor_id)
    invitee = User.find(invitee_id)
    @invitor_name = display_name(invitor)
    @invitee_name = display_name(invitee)

    mail(
      to: invitee.email,
      subject: "You've been assigned a task on Tahi")
  end

  def add_participant(invitor_id, invitee_id, task_id)
    @task = Task.find(task_id)
    invitor = User.find(invitor_id)
    invitee = User.find(invitee_id)
    @invitor_name = display_name(invitor)
    @invitee_name = display_name(invitee)

    mail(
      to: invitee.email,
      subject: "You've been added to a conversation on Tahi")
  end

  def mention_collaborator(comment_id, commentee_id)
    @comment = Comment.find(comment_id)
    @commentor = @comment.user
    @commentee = User.find(commentee_id)

    mail(
      to: @commentee.email,
      subject: "You've been mentioned on Tahi")
  end
end
