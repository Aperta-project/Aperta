require 'rails_helper'

module MailLog::InitializeMessage
  describe DeliveringEmailInterceptor do
    subject(:interceptor) { described_class }

    describe '.delivering_email' do
      let(:mail) { Mail::Message.new }

      it 'sets a message ID on the email' do
        allow(Mail).to receive(:random_tag).and_return '585bfdf2e2e48_fd633fc0f485e1d075412'

        # Mail::Message, per RFC 2822, will strip the angle brackets from the message ID,
        # as only what is *inside* them is the actual message ID.
        expected_message_id = "#{Mail.random_tag}@#{::Socket.gethostname}.mail"

        expect do
          interceptor.delivering_email(mail)
        end.to change { mail.message_id }.from(nil).to expected_message_id
      end

      context 'when the email already has a message_id' do
        before do
          mail.message_id = "<pre-existing-value>"
        end

        it 'does not override pre-existing message ID' do
          expect do
            interceptor.delivering_email(mail)
          end.to_not change { mail.message_id }
        end
      end
    end
  end
end
