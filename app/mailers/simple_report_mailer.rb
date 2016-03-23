# Mailer class for reporting the states papers are in, in the applicaiton.
class SimpleReportMailer < ActionMailer::Base
  include MailerHelper
  layout "mailer"
  default from: Rails.configuration.from_email

  def send_report(simple_report)
    @simple_report = simple_report

    mail(
      to: Rails.configuration.admin_email,
      subject: prefixed("#{app_name} Daily Simple Report"))
  end
end
