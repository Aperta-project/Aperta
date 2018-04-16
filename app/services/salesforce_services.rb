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

# Module for interacting with Salesforce
module SalesforceServices
  class Error < ::StandardError; end
  class SyncInvalid < Error; end

  # Only sends paper data to Salesforce is the paper has been submitted at least
  # once and only sends billing data to Salesforce if the author is requesting
  # publicationn fee assistance.
  def self.sync_paper!(paper, logger: Rails.logger)
    unless TahiEnv.salesforce_enabled?
      Rails.logger.warn(<<-INFO.strip_heredoc.chomp)
        Salesforce integration disabled due to ENV['SALESFORCE_ENABLED']
      INFO
      return
    end

    if paper.latest_submitted_version
      SalesforceServices::PaperSync.sync!(paper: paper)
      logger.info "Salesforce: Paper #{paper.id} sync'd successfully"

      answer = paper.answer_for('plos_billing--payment_method')
      should_send_billing_to_salesforce = answer.try(:value) == "pfa"

      if should_send_billing_to_salesforce
        SalesforceServices::BillingSync.sync!(paper: paper)
        logger.info(
          "Salesforce: Billing info on Paper #{paper.id} sync'd successfully"
        )
      else
        logger.info(
          "Salesforce: Paper #{paper.id} is not PFA, skipping billing sync."
        )
      end
    end
  end
end
