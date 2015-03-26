class FeedbackMailer < ActionMailer::Base

  def contact(user, feedback)
    @user = user
    @feedback = feedback

    mail(
      from: user.email,
      to: ENV['ADMIN_EMAIL'],
      subject: "Tahi Feedback")
  end
end
