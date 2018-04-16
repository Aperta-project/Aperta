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

module PlosBilling
  # Async worker for SFDC manuscript updates
  class SalesforceManuscriptUpdateWorker
    include Sidekiq::Worker

    # 10 retries is approximately 2 ~ 3 hours. See
    # https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry
    # for retry formula
    sidekiq_options retry: 10
    sidekiq_retries_exhausted { |msg| email_admin_on_sidekiq_error(msg) }

    def self.email_admin_on_sidekiq_error(msg)
      error_message = <<-ERROR.strip_heredoc.chomp
        Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}
      ERROR
      paper_id = msg['args'][0]
      email_admin_error(paper_id, error_message)
    end

    def self.email_admin_error(paper_id, error_message)
      BillingSalesforceMailer
        .delay
        .notify_site_admins_of_syncing_error(paper_id, error_message)
    end

    def perform(paper_id)
      paper = ::Paper.find(paper_id)
      SalesforceServices.sync_paper!(paper)
    rescue ActiveRecord::RecordNotFound => ex
      message = record_not_found_error_message(ex, paper_id: paper_id)
      logger.error message
    rescue SalesforceServices::SyncInvalid => ex
      message = sync_invalid_error_message(ex, paper_id: paper_id)
      logger.error message
      self.class.email_admin_error(paper_id, message)
    end

    private

    def record_not_found_error_message(ex, paper_id:)
      <<-MESSAGE.strip_heredoc
        #{self.class.name}#perform failed because the Paper with id=#{paper_id}
        does not exist. The paper was likely deleted before this job ran.

        Original error: #{ex.message}
        Backtrace: #{ex.backtrace.join("\n")}
      MESSAGE
    end

    def sync_invalid_error_message(ex, paper_id:)
      <<-MESSAGE.strip_heredoc
        #{self.class.name}#perform failed due to an #{ex.class} being raised
        while trying to sync Paper with id=#{paper_id}

        Original error: #{ex.message}
        Backtrace: #{ex.backtrace.join("\n")}
      MESSAGE
    end
  end
end
