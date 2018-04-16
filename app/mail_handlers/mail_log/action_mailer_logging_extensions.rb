# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
