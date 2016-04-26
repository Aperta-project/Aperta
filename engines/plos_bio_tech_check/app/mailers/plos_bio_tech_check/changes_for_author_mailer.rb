module PlosBioTechCheck
  class ChangesForAuthorMailer < ActionMailer::Base
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

    def notify_paper_tech_fixed admin_id:, paper_id:
      @admin = User.find admin_id
      @paper = Paper.find paper_id

      mail(to: @admin.email,
           subject: 'Author has submitted tech check fixes')
    end
  end
end
