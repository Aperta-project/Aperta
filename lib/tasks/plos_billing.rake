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

namespace :plos_billing do
  task :retry_salesforce_case_for_paper, [:paper_id] => :environment do |_task, args|
    paper = Paper.find(args[:paper_id])
    SalesforceServices::API.delay.ensure_pfa_case(paper_id: paper.id) if paper.billing_card
  end

  # Usage:
  #   rake plos_billing:upload_log_file_to_s3[33]
  #   where:
  #     args[:paper_id] => "33"
  desc "Uploads a CSV billing log file to S3"
  task :upload_log_file_to_s3, [:paper_id] => :environment do |_t, args|
    if args[:paper_id]
      Rails.logger.info "Starting Billing csv upload to S3 job"
      paper = Paper.find args[:paper_id]
      bl =
        BillingLog.new(paper: paper).populate_attributes
      if bl.save_and_send_to_s3!
        puts("Uploaded #{bl.filename} \n #{bl.csv_file.url}")
      else
        puts("Error in saving file for paper id: #{args[:paper_id]}")
      end
    else
      puts "Missing paper_id. Please see usage instructions in #{__FILE__}"
    end
  end

  # Usage:
  #   rake 'plos_billing:generate_billing_log'
  desc "Generate a billing log file"
  task :generate_billing_log do |_t, _args|
    Rails.logger.info "Starting Billing log job"
    report = BillingLogReport.create!

    if report.papers?
      report.save_and_send_to_s3!
      puts "Uploaded to #{report.csv_file.url}"
    else
      puts 'There were no accepted papers with billing tasks left to process'
    end
  end
end
