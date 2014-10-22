class Feedback < MailForm::Base
  attribute :email_to,
            :env,
            :feedback,
            :referrer,
            :user


  def headers
    {
      subject: 'Tahi Feedback',
      to: email_to,
      user: user.username,
      from: user.email
    }
  end
end
