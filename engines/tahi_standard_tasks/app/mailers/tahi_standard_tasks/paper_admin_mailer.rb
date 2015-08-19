module TahiStandardTasks
  class PaperAdminMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_admin_of_editor_invite_accepted(paper_id:, editor_id:)
      @paper = Paper.find paper_id
      @journal = @paper.journal
      @admin = @paper.admin
      @editor = User.find editor_id

      mail(
        to: @admin.email,
        subject: "#{@editor.full_name} has accepted editor invitation on \"#{@journal.name}: #{@paper.display_title}\""
      )
    end
  end
end
