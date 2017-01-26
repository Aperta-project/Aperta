module MailLog
  # ActionMailerLoggingExtensions is a module that contains
  # extensions to ActionMailer::Base. For example, it will add an after_action
  # callback which stores additional context about an email.
  #
  # It does this pseudo-magically by pulling out instance variables from the
  # mailer instance itself. The trade-off for this magic is that it does not
  # require a developer to remember to explicitly log information in every
  # single mailer action/method.
  module ActionMailerLoggingExtensions
    extend ActiveSupport::Concern

    included do
      after_action :set_aperta_mail_context
    end

    def set_aperta_mail_context
      # ActionMailer provides its own set of private instance variables prefixed
      # with an underscore so filter those out (as we only want Aperta-set
      # instance variables).
      aperta_ivars = instance_variables.select { |ivar| ivar !~ /@_/ }
      aperta_ivar_hash = aperta_ivars.each_with_object({}) do |ivar, hash|
        hash[ivar] = instance_variable_get(ivar)
      end
      message.aperta_mail_context = ApertaMailContext.new(aperta_ivar_hash)
    end
  end
end
