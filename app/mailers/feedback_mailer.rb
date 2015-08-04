class FeedbackMailer < ActionMailer::Base
  include MailerHelper
  layout "mailer"

  def contact(user, feedback)
    @user = user
    @feedback = feedback

    mail(
      from: user.email,
      to: Rails.configuration.admin_email,
      subject: "#{app_name} Feedback")
  end
end
