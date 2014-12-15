class Feedback < MailForm::Base
  attribute :email_to,
            :env,
            :screenshots,
            :feedback,
            :referrer,
            :user

  def email_to
    ENV['ADMIN_EMAIL']
  end

  def env
    Rails.env
  end
  
  def headers
    {
      subject: 'Tahi Feedback',
      to: email_to,
      user: user.username,
      from: user.email
    }
  end
end
