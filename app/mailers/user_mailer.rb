class UserMailer < ActionMailer::Base
  default from: ENV['FROM']

  def add_collaborator(invitor, invitee, paper)
    @paper = paper
    @invitor_name = name(invitor)
    @invitee_name = name(invitee)
    mail(
      to: invitee.email,
      subject: "someone added you as a collaborator!")
  end

  private
  def name(user)
    user.full_name.present? ? user.full_name : user.username
  end
end
