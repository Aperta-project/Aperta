class FeedbackMailer < ApplicationMailer
  include MailerHelper
  layout 'mailer_unstyled'

  def contact(user, feedback)
    @user = user
    @feedback = feedback

    mail(
      from: user.email,
      to: Rails.configuration.x.admin_email,
      subject: prefixed("#{app_name} Feedback"))
  end
end
