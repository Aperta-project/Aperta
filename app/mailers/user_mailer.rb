class UserMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM_EMAIL']

  def add_collaborator(invitor, invitee, paper)
    @paper = paper
    @invitor_name = name(invitor)
    @invitee_name = name(invitee)
    mail(
      to: invitee.email,
      subject: "You've been added as a collaborator to a paper on Tahi")
  end

  private
  def name(user)
    user.full_name.present? ? user.full_name : user.username
  end
end
