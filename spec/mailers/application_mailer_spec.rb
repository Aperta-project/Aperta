require 'rails_helper'
require 'aperta_source_code'

# SampleTestMailer is defined to show that the functionality tested later in
# this spec applies to _all_ mailers. There is nothing a developer needs to
# remember to add later if the below examples are working.
class SampleTestMailer < ApplicationMailer
  def send_email(to:, from:, subject:, body:)
    mail(to: to, from: from, subject: subject, body: body)
  end
end

describe ApplicationMailer do
  describe <<-DESC.strip_heredoc do
    logs emails to the database

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

  describe <<-DESC.strip_heredoc do
    reinforces the convention for logging as much contextual information

    The convention is this: use instance variables rather than local variables
    because they can be pulled out and logged without having to require a human
    to remember to log every minute detail down the road.
  DESC

    #
    # A little meta-programming magic in this spec so we can define a set of
    # examples for each mailer file individually.
    #
    mailer_paths = Dir[Rails.root.to_s + '/**/*_mailer.rb' ]
    mailer_paths.each do |full_mailer_path|
      mailer_path = Pathname.new(full_mailer_path).relative_path_from(Rails.root)
      describe "#{mailer_path}" do
        it 'does not allow subclassing of ActionMailer::Base' do
          visitor = ApertaSourceCodeVisitors::ClassDefinitionVisitor.new
          walker = ApertaSourceCode.new(visitor)
          walker.walk_file(mailer_path)

          visitor.class_definitions.each_pair do |klass_name, definition|
            if klass_name != 'ApplicationMailer' && definition[:superclass] == 'ActionMailer::Base'
              raise RSpec::Expectations::ExpectationNotMetError, <<-ERROR.strip_heredoc
                #{klass_name} subclasses ActionMailer::Base and it shouldn't. It should
                subclass ApplicationMailer. This is to help migrate mailer code to
                Rails 5 conventions as well as support Aperta-specific modifications
                to mailers.

                Please change the definition to match:

                  class #{klass_name} < ApplicationMailer
                    ...
                  end

                For more information please see the latest Rails guide on using
                ActionMailer: http://guides.rubyonrails.org/action_mailer_basics.html
              ERROR
            end
          end
        end

        it 'does not allow local variables to be used in mailer actions (use instance variables instead)' do
          visitor = ApertaSourceCodeVisitors::InstanceMethodAssignmentsVisitor.new
          walker = ApertaSourceCode.new(visitor)

          walker.walk_file(mailer_path)
          visitor.assignments_by_method_name.each_pair do |method_name, method_hash|
            if method_hash[:local_variables].any?
              raise RSpec::Expectations::ExpectationNotMetError, <<-ERROR.strip_heredoc
                The mailer action/method ##{method_name} in #{mailer_path} has local variable
                assignments when it shouldn't. Mailers should only use instance variable
                assignments to enable automatic logging of mailer context.

                Local variables assigned: #{method_hash[:local_variables].join(', ')}

                NOTE: The reason this exists is so that we can log as much information
                about emails as possible. By relying on instance variables as a convention
                it means that future developers don't have to remember to log everything.
                The hope is that this means touching less files over time and having more
                robust audit trails.

                For more information on automatic logging check out config/initializers/action_mailer.rb
                and the app/mail_handlers/ directory.
              ERROR
            end
          end
        end
      end
    end
  end
end
