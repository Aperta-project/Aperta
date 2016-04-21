class FeedbackMailer < ActionMailer::Base
  include MailerHelper
  layout "mailer"

  def contact(user, feedback)
    @user = user
    @feedback = feedback

    mail(
      from: user.email,
      to: Rails.configuration.x.admin_email,
      subject: prefixed("#{app_name} Feedback"))
  end
end
