require 'rails_helper'

# SampleTestMailer is defined to show that the functionality tested later in
# this spec applies to _all_ mailers. There is nothing a developer needs to
# remember to add later if the below examples are working.
class SampleTestMailer < ActionMailer::Base
  def send_email(to:, from:, subject:, body:)
    mail(to: to, from: from, subject: subject, body: body)
  end
end

describe <<-DESC.strip_heredoc do
  ActionMailer::Base functionality.

  This spec is a functional test that ensures that behavior related to
  sending emails thru ActionMailer is in place. It is to ensure that
  the individual pieces (e.g. mail interceptors, observers, delivery handlers,
  etc) are wired up.

  Note: this spec also relies on some ActionMailer configuration that likely
  happens in a config/initializer/* file that is responsible for wiring things
  up.
DESC
  subject(:mailer) { SampleTestMailer }

  let(:deliver_email) do
    mailer.send_email(
      to: 'bob@example.com',
      from: 'sender@example.com',
      subject: 'this is the subject',
      body: 'this is body'
    ).deliver_now
  end

  let(:deliver_email_raise_exception) do
    mail = mailer.send_email(
      to: 'bob@example.com',
      from: 'sender@example.com',
      subject: 'this is the subject',
      body: 'this is body'
    )

    # Simulate an SMTP-like delivery failure
    allow(mail.delivery_method).to receive(:deliver!)
      .and_raise Exception, 'Failed to send!'

    expect { mail.deliver_now }.to raise_error Exception
  end

  it 'logs a sent email to the database' do
    expect do
      deliver_email
    end.to change { EmailLog.count }.by +1
    email_log = EmailLog.last
    expect(email_log.message_id).to be
    expect(email_log.subject).to eq 'this is the subject'
    expect(email_log.status).to eq 'sent'
    expect(email_log.sent_at).to be
    expect(email_log.errored_at).to be nil
  end

  context 'when delivery fails and an exception is raised' do
    it 'logs a errored email to the database' do
      expect do
        deliver_email_raise_exception
      end.to change { EmailLog.count }.by +1
      email_log = EmailLog.last
      expect(email_log.message_id).to be
      expect(email_log.subject).to eq 'this is the subject'
      expect(email_log.status).to eq 'failed'
      expect(email_log.sent_at).to be nil
      expect(email_log.errored_at).to be
    end
  end
end
