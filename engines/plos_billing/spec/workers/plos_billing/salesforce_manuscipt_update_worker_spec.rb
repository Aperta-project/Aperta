require 'rails_helper'

describe PlosBilling::SalesforceManuscriptUpdateWorker do
  describe 'sidekiq_retries_exhausted_block' do
    it 'does not queue up any emails' do
      expect do
        msg = {
          'class' => 'FooBar',
          'args' => [],
          'error_message' => 'something bad happened'
        }
        described_class.sidekiq_retries_exhausted_block.call(msg)
      end.to_not change { Sidekiq::Extensions::DelayedMailer.jobs.length }
    end
  end

  describe '.email_admin_on_sidekiq_error' do
    let(:dbl) { double }
    let(:msg) do
      {
        'class' => 'SomeClass',
        'args' => [4],
        'error_message' => 'some message'
      }
    end
    let(:error_message) do
      "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    end

    it 'does not call BillingSalesforceMailer' do
      expect(PlosBilling::BillingSalesforceMailer).to_not receive(:delay)
      described_class.email_admin_on_sidekiq_error(msg)
    end
  end

  describe '#perform' do
    subject(:perform) { worker.perform(paper.id) }
    let(:worker) { described_class.new }
    let!(:paper) { FactoryGirl.create(:paper, id: 88) }
    let(:logger) { Logger.new(log_io) }
    let(:log_io) { StringIO.new }

    before do
      @original_sidekiq_logger = Sidekiq.logger
      Sidekiq.logger = logger
    end

    after do
      Sidekiq.logger = @original_sidekiq_logger
    end

    it 'syncs the paper with Salesforce' do
      expect(SalesforceServices).to receive(:sync_paper!).with(paper)
      perform
    end

    context 'and the paper does not exist' do
      before { paper.destroy }

      it 'does not sync the paper to Salesforce' do
        expect(SalesforceServices).to_not receive(:sync_paper!)
        perform
      end

      it 'logs the error' do
        perform
        expect(log_io.tap(&:rewind).read).to \
          match(/Couldn't find Paper.*#{paper.id}/)
      end
    end

    context 'and syncing to Salesforce raises a SyncInvalid error' do
      before do
        expect(SalesforceServices).to receive(:sync_paper!)
          .and_raise(SalesforceServices::SyncInvalid, "Couldn't do it")
      end

      it 'logs the error' do
        perform
        expect(log_io.tap(&:rewind).read).to \
          match(/Couldn't do it/)
      end

      it 'does not queue up any emails' do
        expect do
          perform
        end.to_not change { Sidekiq::Extensions::DelayedMailer.jobs.length }
      end
    end
  end
end
