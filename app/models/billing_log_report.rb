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

require 'csv'
# If no date is provided it defaults to last run
class BillingLogReport < ActiveRecord::Base
  include ViewableModel
  ACTIVITY_MESSAGE = 'Billing uploaded to FTP Server'.freeze

  mount_uploader :csv_file, BillingLogUploader

  after_create :log_creation

  def log_creation
    logger.info "Billing log created"
  end

  def save_and_send_to_s3!
    update!(csv_file: csv)
  end

  def papers?
    papers_to_process.present?
  end

  def csv
    @csv ||= create_csv
  end

  def print
    logger.info 'Outputting billing log file'
    logger.info '**************'
    File.open(csv, 'r') do |f|
      while (line = f.gets)
        logger.info line
      end
    end
    logger.info '**************'
  end

  def create_csv
    path = Tempfile.new(['billing-log', '.csv'])
    CSV.open(path, 'w') do |new_csv|
      if papers?
        new_csv << billing_json(papers_to_process.first).keys
        papers_to_process.includes(:journal).find_each(batch_size: 50) { |paper|
          billing_log = BillingLog.new(paper: paper).populate_attributes
          billing_log.save
          new_csv << billing_json(paper).values
        }
      else
        new_csv << ['No accepted papers with completed billing']
      end
    end
    path
  end

  def papers_to_process
    @papers ||= begin
      papers = accepted_papers_with_completed_billing_tasks
      sent_papers = Activity.where(message: BillingLogReport::ACTIVITY_MESSAGE)
                            .map(&:subject)
                            .map!(&:id)
      papers.where.not(id: sent_papers)
    end
  end

  private

  def accepted_papers_with_completed_billing_tasks
    Paper.accepted.joins(:tasks)
      .where(tasks: { completed: true,
                      type: PlosBilling::BillingTask.sti_name })
  end

  def billing_json(paper)
    JSON.parse(Typesetter::BillingLogSerializer.new(paper)
                                               .to_json)['billing_log']
  end

  def current_time
    Time.current.strftime("%Y-%m-%d %H:%M:%S")
  end
end
