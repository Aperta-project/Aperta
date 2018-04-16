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

module SalesforceServices
  # BillingSync is responsible for validating the details of a paper's
  # billing information from the perspective of what PLOS wants in Salesforce
  # and then sync'ing that information.
  class BillingSync < Sync
    delegate :billing_task, to: :@paper, allow_nil: true
    delegate :financial_disclosure_task, to: :@paper, allow_nil: true
    delegate :salesforce_manuscript_id, to: :@paper, allow_nil: true

    validates :paper, :billing_task, presence: true
    validates :salesforce_api, presence: true
    validates :salesforce_manuscript_id, presence: true
    validate :financial_disclosure_exists

    attr_accessor :paper, :salesforce_api

    def initialize(paper:, salesforce_api: SalesforceServices::API)
      @paper = paper
      @salesforce_api = salesforce_api
    end

    # Syncs the paper's billing information to Salesforce if the sync is valid.
    # Otherwise, raises a SyncInvalid error.
    def sync!
      if valid?
        @salesforce_api.ensure_pfa_case(paper: @paper)
      else
        raise SyncInvalid, sync_invalid_message
      end
    end

    private

    def financial_disclosure_exists
      unless financial_disclosure_asked?
        errors.add(:base, "Financial Disclosure question was not asked on this paper")
      end
    end

    def financial_disclosure_asked?
      @financial_disclosure_asked ||= FinancialDisclosureStatement.new(paper).asked?
    end

    def sync_invalid_message
      <<-MESSAGE.strip_heredoc
        The paper's billing information cannot be sent to Salesforce because it
        has missing or invalid information:

        #{errors.full_messages.join("\n")}

        The paper was: #{@paper.inspect}
        The billing task was: #{billing_task.inspect}
        The financial disclosure #{financial_disclosure_asked? ? "exists" : "does not exist"}
      MESSAGE
    end
  end
end
