class GenericMailer < ActionMailer::Base
  include MailerHelper
  default from: Rails.configuration.from_email
  layout "mailer"

  def send_email(subject:, body:, to:)
    @email_body = body.gsub("\n", '<br>')
    @plain_text_body = Nokogiri::HTML(body.gsub('<br>', "\n\n")).text
    mail(to: to, subject: subject)
  end
end
