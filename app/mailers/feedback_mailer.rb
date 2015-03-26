class FeedbackMailer < ActionMailer::Base

  def contact(user, feedback)
    @user = user
    @feedback = feedback

    mail(
      from: user.email,
      to: Rails.configuration.admin_email,
      subject: "Tahi Feedback")
  end
end
