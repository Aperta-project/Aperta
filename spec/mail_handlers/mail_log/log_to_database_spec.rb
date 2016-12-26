require 'rails_helper'

module MailLog::LogToDatabase
  describe DeliveringEmailInterceptor do
    subject(:interceptor) { described_class }

    describe '.delivering_email' do
      let(:mail) do
        Mail::Message.new do
          from 'apertian@plos.org'
          to ['curtis@example.com', 'zach@example.com']
          subject 'This is a test email'
          message_id 'abc123'
        end
      end

      it 'logs the email to the database' do
        expect do
          interceptor.delivering_email(mail)
        end.to change { EmailLog.count }.by +1
        email_log = EmailLog.last
        expect(email_log.from).to eq 'apertian@plos.org'
        expect(email_log.to).to eq 'curtis@example.com, zach@example.com'
        expect(email_log.message_id).to eq 'abc123'
        expect(email_log.raw_source).to eq mail.to_s
        expect(email_log.status).to eq 'pending'
        expect(email_log.sent_at).to be nil
        expect(email_log.errored_at).to be nil
      end
    end
  end

  describe DeliveredEmailObserver do
    subject(:observer) { described_class }

    describe '.delivered_email' do
      let(:mail) do
        Mail::Message.new do
          message_id 'abc123'
        end
      end

      let!(:email_log) do
        EmailLog.create!(message_id: 'abc123', status: 'pending')
      end

      it 'marks the logged email record as sent' do
        expect do
          observer.delivered_email(mail)
        end.to change { email_log.reload.status }.from('pending').to('sent')
      end

      it 'sets the sent_at timestamp on the logged email record' do
        Timecop.freeze do |now|
          observer.delivered_email(mail)
          expect(email_log.reload.sent_at).to be_within_db_precision.of(now)
        end
      end
    end
  end

  describe EmailExceptionsHandler do
    subject(:delivery_handler) { described_class.new }

    describe '.deliver_mail' do
      let(:mail) do
        Mail::Message.new do
          message_id 'abc123'
        end
      end

      let!(:email_log) do
        EmailLog.create!(message_id: 'abc123', status: 'sent')
      end

      it 'yields the given block' do
        expect do |block|
          delivery_handler.deliver_mail(mail, &block)
        end.to yield_control
      end

      context 'when the given block raises an exception' do
        let(:deliver_mail_with_exception) do
          expect do
            delivery_handler.deliver_mail(mail) { raise Exception, "It failed!" }
          end.to raise_error(Exception)
        end

        it 'sets the logged email record status to failed; raises the exception' do
          deliver_mail_with_exception
          email_log.reload
          expect(email_log.status).to eq('failed')
          expect(email_log.error_message).to eq('It failed!')
        end

        it 'sets the failed_at timestamp on the logged email record' do
          Timecop.freeze do |now|
            deliver_mail_with_exception
            expect(email_log.reload.errored_at).to be_within_db_precision.of(now)
          end
        end
      end
    end
  end
end
