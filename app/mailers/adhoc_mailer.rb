class AdhocMailer < ActionMailer::Base
  include MailerHelper
  default from: ENV.fetch('FROM_EMAIL')

  def send_adhoc_email(subject, body, user_ids)
    users = User.where("id IN (?)", user_ids)

    users.each do |user|
      mail(to: user.email, subject: subject, body: body)
    end
  end
end
