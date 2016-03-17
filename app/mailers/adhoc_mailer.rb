class AdhocMailer < ActionMailer::Base
  include MailerHelper
  default from: Rails.configuration.from_email
  layout "mailer"

  def send_adhoc_email(subject, body, user)
    @email_body = body
    @plain_text_body = Nokogiri::HTML(body.gsub('<br>', "\n\n")).text
    mail(to: user.email, subject: subject)
  end
end
