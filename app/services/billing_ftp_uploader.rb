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

# This service is used to FTP the BillingLogReport to billing ftp server.
class BillingFTPUploader
  attr_reader :billing_log_report, :ftp_enabled, :logger

  # === Constructor Arguments
  # billing_log_report - this is required
  # ftp_enabled: Optional. Default is pulled from BILLING_FTP_ENABLED env var
  # ftp_url: Optional. Default is pulled from BILLING_FTP_URL env var
  # logger: Optional. Default is Rails.logger.
  def initialize(
    billing_log_report,
    ftp_enabled: TahiEnv.billing_ftp_enabled?,
    ftp_url: TahiEnv.billing_ftp_url,
    logger: Rails.logger
  )
    if billing_log_report.nil?
      raise ArgumentError, 'The billing_log_report cannot be nil'
    end
    @billing_log_report = billing_log_report
    @ftp_enabled = ftp_enabled
    @ftp_url = ftp_url
    @logger = logger
  end

  def upload
    if ftp_enabled
      ftp_uploader.upload
      true
    else
      logger.warn "Billing FTP is not enabled."
      false
    end
  end

  def timestamped_filename
    upload_datetime = Time.zone.now.strftime "%Y%m%d-%H%M"
    "aperta-billing-#{upload_datetime}.csv"
  end

  private

  def ftp_uploader
    @ftp_uploader ||= begin
      FtpUploaderService.new(
        file_io: @billing_log_report.csv,
        final_filename: timestamped_filename,
        url: @ftp_url,
        email_on_failure: emails_to_notify_on_failure,
        error_detail: error_detail
      )
    end
  end

  def error_detail
    "#{@billing_log_report.papers_to_process.count} papers with the"\
    " following IDs were not sent to billing: #{paper_ids}"
  end

  def paper_ids
    @billing_log_report.papers_to_process.map(&:id).join(', ')
  end

  # Returns the email addresses that should be used for notifications
  # in the case that FTP fails. When the BillingLogReport has papers then
  # return the staff admins on those papers journals. Otherwise, fallback
  # to all staff admins on all journals.
  def emails_to_notify_on_failure
    if billing_log_report.papers_to_process.any?
      Journal.staff_admins_for_papers(
        billing_log_report.papers_to_process
      ).map(&:email).uniq
    else
      Journal.staff_admins_across_all_journals
      .map(&:email)
    end
  end
end
