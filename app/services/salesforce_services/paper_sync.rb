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
  # PaperSync is responsible for validating the details of a paper's
  # information from the perspective of what PLOS wants in Salesforce
  # and then sync'ing that information.
  class PaperSync < Sync
    validates :paper, :salesforce_api, presence: true

    attr_accessor :paper, :salesforce_api

    def initialize(paper:, salesforce_api: SalesforceServices::API)
      @paper = paper
      @salesforce_api = salesforce_api
    end

    # Syncs the paper to Salesforce if valid. Otherwise, raises SyncInvalid.
    def sync!
      if valid?
        @salesforce_api.find_or_create_manuscript(paper: @paper)
      else
        raise SyncInvalid, sync_invalid_message
      end
    end

    private

    def sync_invalid_message
      <<-MESSAGE.strip_heredoc
        The paper cannot be sent to Salesforce because it has missing
        or invalid information:

        #{errors.full_messages.join("\n")}

        The paper was: #{@paper.inspect}
      MESSAGE
    end
  end
end
