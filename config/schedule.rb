env :SHELL, '/bin/bash'
env :PATH, '/bin:/usr/bin:/usr/local/bin'
env :HOME, '/home/aperta'
env :MAILTO, 'apertadevteam@plos.org'

job_type :rake, "cd :path && chruby-exec #{RUBY_VERSION} -- "\
                "bundle exec dotenv -f env rake :task --silent :output"

every :day, at: '00:01' do
  rake 'clean:temp_files'
  rake 'reports:analyze_attachments:send_email[apertadevteam@plos.org]'
end
