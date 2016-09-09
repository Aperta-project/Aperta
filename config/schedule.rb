env :SHELL, '/bin/bash'
env :PATH, '/bin:/usr/bin:/usr/local/bin'
env :HOME, '/home/aperta'

job_type :rake, "cd :path && chruby-exec #{RUBY_VERSION} -- "\
                "bundle exec dotenv -f env rake :task --silent :output"

every :day, at: '00:01' do
  rake 'plos_billing:daily_billing_log_export'
  rake 'clean:temp_files'
end

every :day, at: '09:00' do
  rake 'simple_report'
end
