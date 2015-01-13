require 'rails_helper'

describe IhatJobsController, :type => :controller do

  describe "PUT update" do
    before do
      token = ApiKey.generate!
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:encrypted_metadata) { Verifier.new(paper_id: "123").encrypt }
    let(:ihat_job_params) { { job: { id: 4, state: ihat_job_state, metadata: encrypted_metadata, url: "http://amazon.localhost/1234" } } }

    context "the ihat job status is 'converted'" do
      let(:ihat_job_state) { "converted" }

      it "calls the PaperUpdateWorker" do
        expect(PaperUpdateWorker).to receive(:perform_async).with("123", "http://amazon.localhost/1234")
        put :update, ihat_job_params
      end

      it "returns success" do
        allow(PaperUpdateWorker).to receive(:perform_async)
        put :update, ihat_job_params
        expect(response.status).to eq(200)
      end
    end

    context "the ihat job status is not 'converted'" do
      let(:ihat_job_state) { "errored" }

      it "does not call the PaperUpdateWorker" do
        expect(PaperUpdateWorker).to_not receive(:perform_async)
        put :update, ihat_job_params
      end

      it "returns success" do
        allow(PaperUpdateWorker).to receive(:perform_async)
        put :update, ihat_job_params
        expect(response.status).to eq(202)
      end
    end

    context "missing required parameters" do
      let(:ihat_job_state) { "converted" }
      let(:invalid_ihat_job_params) { { job: { id: "4", state: "converted", metadata: {} } } }

      it "returns 422" do
        put :update, invalid_ihat_job_params
        expect(response.status).to eq(422)
      end
    end

  end
end
