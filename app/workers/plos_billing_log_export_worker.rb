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

# PLOS Billing: no longer a fickle rake task but a confident sidekiq job.
class PlosBillingLogExportWorker
  include Sidekiq::Worker
  # twelve retires is at most 6 hours
  sidekiq_options retry: 12

  def perform
    report = BillingLogReport.create!
    report.save_and_send_to_s3! unless report.csv_file.file
    return unless BillingFTPUploader.new(report).upload
    report.papers_to_process.each do |paper|
      Activity.create(
        feed_name: "forensic",
        activity_key: "plos_billing.ftp_uploaded",
        subject: paper,
        message: BillingLogReport::ACTIVITY_MESSAGE
      )
    end
  end
end
