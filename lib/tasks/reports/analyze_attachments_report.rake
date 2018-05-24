# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'tahi_reports/analyze_attachment_failures_report'

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
      Runs the AnalyzeAttachmentFailuresReport and emails the team

      Usage:
        rake reports:analyze_attachments:send_email[me@example.org]

      Note: this can only send to one recipient at a time.
    DESCRIPTION
    task :send_email, [:recipient] => :environment do |_t, args|
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
