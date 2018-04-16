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

module MailLog::LogToRails
  describe DeliveredEmailObserver do
    subject(:observer) { described_class }

    describe '.delivered_email' do
      let(:mail) do
        Mail::Message.new do
          from 'apertian@example.org'
          to ['curtis@example.com', 'zach@example.com']
          subject 'This is a test email'
        end
      end

      let(:logger) { Logger.new(output) }
      let(:output) { StringIO.new }

      it 'logs that the email was sent to the Rails.logger' do
        Timecop.freeze do
          observer.delivered_email mail, logger: logger
          to = mail.to.join(', ')
          from = mail.from.first
          subject = mail.subject
          at = Time.current
          expected = "event=email to=#{to} from=#{from} subject='#{subject}' at=#{at}"
          expect(output.tap(&:rewind).read).to include expected
        end
      end
    end
  end
end
