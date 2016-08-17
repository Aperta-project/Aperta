require 'csv'
# If no date is provided it defaults to last run
class BillingLogReport < ActiveRecord::Base
  mount_uploader :csv_file, BillingLogUploader

  def self.create_report(from_date: nil)
    from_date ||= BillingLogReport.last.created_at if BillingLogReport.any?
    BillingLogReport.new(from_date: from_date)
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
    puts 'Outputting billing log file'
    puts '**************'
    File.open(csv, 'r') do |f|
      while line = f.gets
        puts line
      end
    end
    puts '**************'
  end

  def create_csv
    path = Tempfile.new(['billing-log', '.csv'])
    CSV.open(path, 'w') do |new_csv|
      if papers?
        new_csv << billing_json(papers_to_process.first).keys
        papers_to_process.includes(:journal).find_each(batch_size: 50) do |paper|
          billing_log = BillingLog.new(paper: paper).populate_attributes
          billing_log.save
          new_csv << billing_json(paper).values
        end
      else
        new_csv << ['No accepted papers with completed billing']
      end
    end
    path
  end

  def papers_to_process
    @papers ||= begin
      papers = accepted_papers_with_completed_billing_tasks

      if from_date
        papers.where('tasks.completed_at > ?', from_date)
      else
        papers
      end
    end
  end

  private

  def accepted_papers_with_completed_billing_tasks
    Paper.accepted.joins(:tasks)
      .where(tasks: { completed: true,
                      type: PlosBilling::BillingTask.sti_name })
  end

  def billing_json(paper)
    JSON.parse(
      Typesetter::BillingLogSerializer.new(paper).to_json)['billing_log']
  end

  def current_time
    Time.current.strftime("%Y-%m-%d %H:%M:%S")
  end
end
