namespace :simple_report do
  desc 'Runs a simple paper workflow status report'
  task run: 'environment' do
    SimpleReportMailerWorker.perform_async
  end
end
