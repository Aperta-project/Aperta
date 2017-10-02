# Provides a template context for Sendbacks
class SendbacksContext < TemplateContext
  include ActionView::Helpers::SanitizeHelper
  # def self.complex_merge_fields
  #   [{ name: :reviewer, context: UserContext },
  #    { name: :answers, context: AnswerContext, many: true }]
  # end

  def self.blacklisted_merge_fields
    ActionView::Helpers::SanitizeHelper.public_instance_methods
  end

  # whitelist :intro, :footer, :sendback_reasons

  def intro
    content = version.card_contents
      .find_by(ident: 'tech-check-email--email-intro')
    # wrong
    content.answers.first.value
  end

  def footer
    content = version.card_contents
      .find_by(ident: 'tech-check-email--email-footer')
    # wrong
    content.answers.first.value
  end

  def sendback_reasons
    sendbacks = version.card_contents
      .where(contentType: 'sendback-reasons')
    'x'
    # not sure yet
  end

  private

  def task
    @object
  end

  def version
    task.card_version
  end
end
