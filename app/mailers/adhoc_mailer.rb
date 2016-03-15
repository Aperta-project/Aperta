class AdhocMailer < ActionMailer::Base
  include MailerHelper
  default from: Rails.configuration.from_email
  layout "mailer"

  def send_adhoc_email(subject, body, user)
    mail(to: user.email, subject: subject, body: body)
  end
end
