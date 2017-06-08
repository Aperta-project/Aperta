require 'rails_helper'

describe Ihat::JobsController, type: :controller do

  describe "POST create" do
    before do
      token = ApiKey.generate!
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:encrypted_metadata) { Verifier.new(paper_id: "123", user_id: "456").encrypt }
    let(:ihat_job_params) { { job: { id: 4, state: ihat_job_state, options: { metadata: encrypted_metadata }, outputs: [{ file_type: "epub", url: "http://amazon.localhost/1234" }] }, format: :json } }
    let(:worker_params) do
      { id: 4, state: ihat_job_state,
        options: { metadata: { paper_id: "123", user_id: "456" } },
        outputs: [{ file_type: "epub", url: "http://amazon.localhost/1234" }] }
    end

    context "the ihat job status is 'completed'" do
      let(:ihat_job_state) { "completed" }

      it "calls the PaperUpdateWorker" do
        expect(PaperUpdateWorker).to receive(:perform_async).with(worker_params)
        post :create, ihat_job_params
      end

      it "returns success" do
        allow(PaperUpdateWorker).to receive(:perform_async)
        post :create, ihat_job_params
        expect(response.status).to eq(200)
      end
    end

    context "the ihat job status is not 'completed'" do
      let(:ihat_job_state) { "errored" }

      it "calls the PaperUpdateWorker" do
        expect(PaperUpdateWorker).to receive(:perform_async).with(worker_params)
        post :create, ihat_job_params
      end

      it "returns success" do
        allow(PaperUpdateWorker).to receive(:perform_async)
        post :create, ihat_job_params
        expect(response.status).to eq(200)
      end
    end

    context "missing required parameters" do
      let(:ihat_job_state) { "completed" }
      let(:invalid_ihat_job_params) { { random_hash_of_things: [1, 2, 3] } }

      it "returns 422" do
        post :create, invalid_ihat_job_params
        expect(response.status).to eq(422)
      end
    end
  end
end
