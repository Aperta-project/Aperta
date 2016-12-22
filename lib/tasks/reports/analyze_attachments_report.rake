namespace :reports do
  namespace :analyze_attachments do
    desc <<-DESCRIPTION.strip_heredoc
      Runs the AnalyzeAttachmentFailuresReport and prints to STDOUT.

      Usage:
        rake reports:analyze_attachments:run
    DESCRIPTION
    task run: :environment do
      TahiReports::AnalyzeAttachmentFailuresReport.run(output: STDOUT)
    end

    desc <<-DESCRIPTION.strip_heredoc
      Runs the AnalyzeAttachmentFailuresReport and emails apertadevteam@plos.org.

      Usage:
        rake reports:analyze_attachments:send_email_to_aperta_dev_team

      Note: this is workaround because the version of chruby deployed
      incorrectly escapes square brackets and causes issues when executing
      on ci, rc, production, etc.
    DESCRIPTION
    task send_email_to_aperta_dev_team: :environment do
      task = Rake::Task['reports:analyze_attachments:send_email']
      task.reenable
      task.invoke('apertadevteam@plos.org')
    end

    desc <<-DESCRIPTION.strip_heredoc
      Runs the AnalyzeAttachmentFailuresReport and emails the team

      Usage:
        rake reports:analyze_attachments:send_email[apertadevteam@plos.org]

      Note: this can only send to one recipient at a time.
    DESCRIPTION
    task :send_email, [:recipient] => :environment do |t, args|
      recipient = args[:recipient] || raise(
        ArgumentError,
        <<-ERROR.strip_heredoc
          This rake task must be called with an email recipient.

          See "rake -D reports:analyze_attachments:send_email" for more information.
        ERROR
      )

      require 'stringio'
      report_output = StringIO.new
      TahiReports::AnalyzeAttachmentFailuresReport.run(output: report_output)
      GenericMailer.delay.send_email(
        to: recipient,
        subject: "Attachment Analysis Report for #{Date.today.to_s}",
        body: report_output.tap(&:rewind).read
      )
    end
  end
end
