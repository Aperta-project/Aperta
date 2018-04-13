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

require 'rails_helper'
require 'tahi_reports/analyze_attachment_failures_report'

describe "reports:analyze_attachments" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  describe 'reports:analyze_attachments:run' do
    before do
      Rake::Task['reports:analyze_attachments:run'].reenable
    end

    it 'runs the report, outputting to STDOUT' do
      expect(TahiReports::AnalyzeAttachmentFailuresReport)
        .to receive(:run)
        .with(output: STDOUT)
      Rake.application.invoke_task 'reports:analyze_attachments:run'
    end
  end

  describe 'reports:analyze_attachments:send_email' do
    before do
      Rake::Task['reports:analyze_attachments:run'].reenable
    end

    it 'runs the report and queues up an email to notify the team of its output' do
      expect(TahiReports::AnalyzeAttachmentFailuresReport)
        .to receive(:run) do |**kwargs|
          output = kwargs[:output]
          output.print "report body here"
        end
      Rake.application.invoke_task 'reports:analyze_attachments:send_email[foo@bar.com]'
      expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
        GenericMailer,
        :send_email,
        [{
          to: "foo@bar.com",
          subject: "Attachment Analysis Report for #{Date.today.to_s}",
          body: "report body here"
        }]
      )
    end

    context 'and the task is called without a recipient' do
      before do
        Rake::Task['reports:analyze_attachments:send_email'].reenable
        allow(TahiReports::AnalyzeAttachmentFailuresReport)
          .to receive(:run) do |**kwargs|
            output = kwargs[:output]
            output.print "report body here"
          end
      end

      it 'tells the user what to do if they call the task without a recipient' do
        expect do
          Rake.application.invoke_task 'reports:analyze_attachments:send_email'
        end.to raise_error(
          ArgumentError,
          <<-ERROR.strip_heredoc
            This rake task must be called with an email recipient.

            See "rake -D reports:analyze_attachments:send_email" for more information.
          ERROR
        )
      end

      it 'does not send out any emails' do
        begin
          Rake.application.invoke_task 'reports:analyze_attachments:send_email'
        rescue
        end
        expect(Sidekiq::Extensions::DelayedMailer.jobs.empty?).to be(true)
      end
    end
  end
end
