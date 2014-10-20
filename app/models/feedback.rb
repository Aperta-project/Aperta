class Feedback < MailForm::Base
  attribute :email_to
  attribute :user
  attribute :feedback
  attribute :referrer
  attribute :env

  def headers
    {
      subject: 'Tahi Feedback',
      to: email_to,
      user: user.username,
      from: user.email
    }
  end
end
