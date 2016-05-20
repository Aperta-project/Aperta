require 'csv'
# This service is used to determine the papers that need to be processed
# from a particular date. If no date is provided it defaults to last run
class BillingLogManager
  def initialize(from_date = nil)
    @report_start_time = from_date
  end

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

  def papers_to_process
    @papers ||= begin
      papers = Paper.accepted.joins(:tasks).where(tasks: { completed: true, type: PlosBioTechCheck::FinalTechCheckTask.sti_name })
      if @report_start_time
        papers.where('tasks.completed_at > ?', @report_start_time)
      else
        papers
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

  def save_and_send_to_s3
    s3 = CloudServices::S3Service.new.connection

    directory = s3.directories.new(
      key:    Rails.application.config.s3_bucket,
      public: false
    )

    s3_file = directory.files.create(
      key:    "billing/#{filename}",
      body:   create_csv.string,
      public: true
    )
    # returns true if !errors
    s3_file.save && BillingLog.last.update_column(:s3_url, s3_file.url(1.week.from_now))
  end
end
