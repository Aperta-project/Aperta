task simple_report: 'environment' do
  desc 'Runs a simple paper workflow status report'
  SimpleReportMailerWorker.perform_async
end
