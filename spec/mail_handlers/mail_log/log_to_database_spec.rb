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
        expect(email_log.sender).to eq 'apertian@plos.org'
        expect(email_log.recipients).to eq 'curtis@example.com, zach@example.com'
        expect(email_log.message_id).to eq 'abc123'
        expect(email_log.raw_source).to eq mail.to_s
        expect(email_log.status).to eq 'pending'
        expect(email_log.sent_at).to be nil
        expect(email_log.errored_at).to be nil
        expect(email_log.journal).to be nil
        expect(email_log.paper).to be nil
        expect(email_log.task).to be nil
      end

      context 'and additional context is provided for the email' do
        subject(:perform_delivering_email) do
          mail.aperta_mail_context = MailLog::ApertaMailContext.new(context_hash)
          interceptor.delivering_email(mail)
        end
        let(:attachment) { FactoryGirl.create(:attachment) }
        let(:task) { FactoryGirl.create(:ad_hoc_task) }
        let(:paper) { FactoryGirl.create(:paper) }
        let(:journal) { FactoryGirl.create(:journal) }
        let(:email_log) { EmailLog.last }

        let(:context_hash) do
          {
            '@task' => task,
            '@paper' => paper,
            '@journal' => journal,
            '@attachment' => attachment,
            '@not_activerecord_model' => Object.new
          }
        end

        it 'sets the EmailLog#task to the first Task' do
          perform_delivering_email
          expect(email_log.task).to eq task
        end

        it 'sets the EmailLog#paper to the first Paper' do
          perform_delivering_email
          expect(email_log.paper).to eq paper
        end

        context 'and there is no Paper in the context' do
          before do
            context_hash.delete('@paper')
          end

          it "sets the EmailLog#paper to the task's paper when it's available" do
            perform_delivering_email
            expect(email_log.paper).to eq(task.paper)
            expect(email_log.paper).to_not eq(paper)
          end

          it "sets the EmailLog#paper to the first Paper instance when the instance variable is named something other than /paper/" do
            context_hash.delete('@task')
            misnamed_paper = FactoryGirl.create(:paper)
            context_hash['@misnamed'] = misnamed_paper
            perform_delivering_email
            expect(email_log.paper).to eq(misnamed_paper)
            expect(email_log.paper).to_not eq(task.paper)
            expect(email_log.paper).to_not eq(paper)
          end

          it "sets the EmailLog#paper to the first associated paper found when @task.paper and @paper are blank" do
            context_hash.delete('@task')
            attachment.paper = FactoryGirl.create(:paper)
            perform_delivering_email
            expect(email_log.paper).to eq(attachment.paper)
            expect(email_log.paper).to_not eq(task.paper)
            expect(email_log.paper).to_not eq(paper)
          end
        end

        it 'sets the EmailLog#journal to the first Journal' do
          perform_delivering_email
          expect(email_log.journal).to eq journal
        end

        context 'and there is no Journal in the context' do
          before do
            context_hash.delete('@journal')
          end

          it "sets the EmailLog#journal to the paper's journal" do
            perform_delivering_email
            expect(email_log.journal).to eq(paper.journal)
            expect(email_log.journal).to_not eq(journal)
          end
        end

        it 'sets EmailLog#additional_context to include all of the activerecord models in the mail context' do
          perform_delivering_email
          expect(email_log.additional_context).to eq({
            "@task"=>["AdHocTask", task.id],
            "@paper"=>["Paper", paper.id],
            "@journal"=>["Journal", journal.id],
            "@attachment"=>["Attachment", attachment.id]
          })
          expect(email_log.additional_context.keys).to_not include '@not_activerecord_model'
        end
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
