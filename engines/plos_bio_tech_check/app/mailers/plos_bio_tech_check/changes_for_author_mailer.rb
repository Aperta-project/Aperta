module PlosBioTechCheck
  class ChangesForAuthorMailer < ApplicationMailer
    include Rails.application.routes.url_helpers
    include MailerHelper
    add_template_helper ClientRouteHelper
    default from: ENV.fetch('FROM_EMAIL')
    after_action :prevent_delivery_to_invalid_recipient
    layout 'mailer'

    def notify_changes_for_author author_id:, task_id:
      @author = User.find author_id
      @task = Task.find task_id
      @paper = @task.paper
      @journal = @paper.journal

      mail(to: @author.email,
           subject: "Changes needed on your Manuscript in #{@journal.name}")
    end
  end
end
