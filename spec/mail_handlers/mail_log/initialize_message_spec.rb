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
