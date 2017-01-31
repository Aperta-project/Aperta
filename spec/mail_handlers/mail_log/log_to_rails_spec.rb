require 'rails_helper'

module MailLog::LogToRails
  describe DeliveredEmailObserver do
    subject(:observer) { described_class }

    describe '.delivered_email' do
      let(:mail) do
        Mail::Message.new do
          from 'apertian@plos.org'
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
