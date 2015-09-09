module TahiStandardTasks
  class PaperAdminMailer < ActionMailer::Base
    include Rails.application.routes.url_helpers
    add_template_helper ClientRouteHelper
    layout "mailer"

    default from: Rails.configuration.from_email

    def notify_admin_of_editor_invite_accepted(paper_id:, editor_id:)
      @paper = Paper.find paper_id
      @admin = @paper.admin
      return :paper_admin_does_not_exist unless @admin
      @journal = @paper.journal
      @editor = User.find editor_id

      mail(
        to: @admin.email,
        subject: "#{@editor.full_name} has accepted editor invitation on \"#{@journal.name}: #{@paper.display_title}\""
      )
    end
  end
end
