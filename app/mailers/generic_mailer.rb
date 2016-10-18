class GenericMailer < ActionMailer::Base
  include MailerHelper
  default from: Rails.configuration.from_email
  layout "mailer"

  def send_email(subject, body, addresses)
    @email_body = body
    @plain_text_body = Nokogiri::HTML(body.gsub('<br>', "\n\n")).text
    mail(to: addresses, subject: subject)
  end
end
