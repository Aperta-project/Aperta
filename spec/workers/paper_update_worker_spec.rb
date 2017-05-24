require 'rails_helper'

describe PaperUpdateWorker do
  subject(:worker) { PaperUpdateWorker.new }
  let(:paper) { FactoryGirl.create :paper, processing: true }
  let(:stubbed_url) { "http://s3_url_example" }
  let(:job_state) { 'completed' }
  let(:ihat_job_params) { { state: job_state, options: { metadata: { paper_id: paper.id } }, outputs: [{ file_type: 'epub', url: stubbed_url }] } }

  describe "#perform" do
    let(:turtles_fixture) { File.open(Rails.root.join('spec', 'fixtures', 'turtles.epub'), 'rb').read }

    before do
      VCR.turn_off!
      stub_request(:get, stubbed_url).to_return(body: turtles_fixture)
    end

    after do
      VCR.turn_on!
      expect(WebMock).to have_requested(:get, stubbed_url)
    end

    it "requests attribute extraction" do
      expect_any_instance_of(PaperAttributesExtractor).to receive(:sync!)
      worker.perform(ihat_job_params)
    end

    it "sets the paper's status to 'done'" do
      expect do
        worker.perform(ihat_job_params)
      end.to change { paper.reload.processing }.from(true).to(false)
    end
  end

  describe "#perform on an error" do
    before do
      paper.file = FactoryGirl.create(
        :manuscript_attachment,
          paper: paper,
          file: File.open(Rails.root.join('spec/fixtures/about_turtles.docx')),
          pending_url: 'http://tahi-test.s3.amazonaws.com/temp/about_turtles.docx',
          status: 'error'
      )
    end
    let(:job_state) { 'errored' }
    let(:job_response) { IhatJobResponse.new(ihat_job_params) }

    context "paper.processing=true" do
      it "expect processing to be true when the worker has not been initiated" do
        expect(paper.processing).to eq(true)
        expect(paper.file.status).to eq('error')
      end

      it "sends a notification to the paper:updated event" do
        allow(Notifier).to receive(:notify)
        expect(Notifier).to receive(:notify).with(hash_including(event: "paper:updated")) do |args|
          expect(args[:data][:record]).to eq(paper)
        end
        worker.perform(ihat_job_params)
      end
    end

    context "paper.processing=false" do
      before do
        paper.update processing: false
      end

      it "raises an exception when an error occurs" do
        worker.perform(ihat_job_params)
        expect(paper.reload.processing).to eq(false)
        expect(paper.file.reload.status).to eq('error')
      end

      it "notifies bugsnag" do
        expect(Bugsnag).to receive(:notify)
        worker.perform(ihat_job_params)
      end

      it "sends a notification to the paper:updated event" do
        allow(Notifier).to receive(:notify)
        expect(Notifier).to receive(:notify).with(hash_including(event: "paper:updated")) do |args|
          expect(args[:data][:record]).to eq(paper)
        end
        worker.perform(ihat_job_params)
      end
    end
  end

  describe "retries" do
    it "does not retry" do
      expect(worker.sidekiq_options_hash["retry"]).to be(false)
    end
  end
end
