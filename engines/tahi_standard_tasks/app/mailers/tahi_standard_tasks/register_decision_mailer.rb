module TahiStandardTasks
  class RegisterDecisionMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers

    default from: ENV.fetch('FROM_EMAIL')

    def notify_author_email(decision_id:)
      @decision = Decision.find(decision_id)
      @paper = @decision.paper
      @recipient = User.find(@paper.user_id)

      mail(to: @recipient.email,
           subject: "A Decision has been Registered on #{@paper.title}")
    end
  end
end
