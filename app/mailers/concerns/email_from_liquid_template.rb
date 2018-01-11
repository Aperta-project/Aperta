module EmailFromLiquidTemplate
  extend ActiveSupport::Concern

  private

  def send_mail_from_letter_template(journal:, letter_ident:, scenario:, check_blanks: false)
    @letter_template = journal.letter_templates.find_by(ident: letter_ident)
    @letter_template.render(scenario, check_blanks: check_blanks)
    @subject = @letter_template.subject
    @body = @letter_template.body
    @to = @letter_template.to
    @cc = @letter_template.cc
    @bcc = @letter_template.bcc
    mail(to: @to, cc: @cc, bcc: @bcc, subject: @subject)
  rescue BlankRenderFieldsError => e
    Bugsnag.notify(e)
  end
end
