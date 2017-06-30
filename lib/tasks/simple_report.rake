desc 'Runs a simple paper workflow status report'
task simple_report: 'environment' do
  SimpleReportWorker.perform_async
end
