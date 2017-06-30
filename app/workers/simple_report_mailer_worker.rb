# Worker class for generating and saving a new SimpleReport.
# Intended to be called by a scheduled task, or on an ad-hoc basis.
class SimpleReportMailerWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5

  def perform
    simple_report = SimpleReport.build_new_report
    simple_report.save!
  end
end
