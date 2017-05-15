desc 'Runs a simple paper workflow status report'
task simple_report: 'environment' do
  SimpleReportMailerWorker.perform_async
end
