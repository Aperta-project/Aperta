require 'csv'
# If no date is provided it defaults to last run
class BillingLogReport < ActiveRecord::Base
  mount_uploader :csv_file, BillingLogUploader
  def papers_to_process
    @papers ||= begin
      papers = Paper.accepted.joins(:tasks).where(tasks: { completed: true, type: PlosBioTechCheck::FinalTechCheckTask.sti_name })
      if from_date
        papers.where('tasks.completed_at > ?', from_date)
      else
        papers
      end
    end
  end

  def billing_json(paper)
    JSON.parse(
      Typesetter::BillingLogSerializer.new(paper).to_json)['billing_log']
  end

  def current_time
    Time.current.strftime("%Y-%m-%d %H:%M:%S")
  end

  def filename
    @filename ||=
    "billing-log-#{current_time}.csv"
  end

  def self.create_report(from_date: nil)
    from_date ||= BillingLogReport.last.created_at if BillingLogReport.any?
    BillingLogReport.new(from_date: from_date).tap(&:save_and_send_to_s3!)
  end

  def save_and_send_to_s3!
    return nil unless papers_to_process.present?
    tmp_file = Tempfile.new('')
    tmp_file.write(create_csv.string)
    update!(csv_file: tmp_file)
  end

  private

  def create_csv
    csv = CSV.new ""
    csv << billing_json(papers_to_process.first).keys
    papers_to_process.includes(:journal).find_each(batch_size: 50) do |paper|
      billing_log = BillingLog.new(paper: paper, journal: paper.journal).populate_attributes
      billing_log.save
      csv << billing_json(paper).values
    end
    csv
  end
end
