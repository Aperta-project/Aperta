# Worker class for generating a new SimpleReport, mailing it, and saving if
# successful. Intended to be called by a scheduled task, or on an ad-hoc
# basis.
class SimpleReportMailerWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    simple_report = SimpleReport.build_new_report
    SimpleReportMailer.send_report(simple_report).deliver_now
    simple_report.save!
  end
end
