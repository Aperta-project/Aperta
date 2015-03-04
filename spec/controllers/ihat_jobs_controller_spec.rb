require 'rails_helper'

describe IhatJobsController, :type => :controller do

  describe "POST update" do
    before do
      token = ApiKey.generate!
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:encrypted_metadata) { Verifier.new(paper_id: "123").encrypt }
    let(:ihat_job_params) { { job: { id: 4, state: ihat_job_state, options: { metadata: encrypted_metadata }, outputs: [{ file_type: "epub", url: "http://amazon.localhost/1234" }] } } }

    context "the ihat job status is 'completed'" do
      let(:ihat_job_state) { "completed" }

      it "calls the PaperUpdateWorker" do
        expect(PaperUpdateWorker).to receive(:perform_async).with("123", "http://amazon.localhost/1234")
        post :update, ihat_job_params
      end

      it "returns success" do
        allow(PaperUpdateWorker).to receive(:perform_async)
        post :update, ihat_job_params
        expect(response.status).to eq(200)
      end
    end

    context "the ihat job status is not 'completed'" do
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
      let(:ihat_job_state) { "completed" }
      let(:invalid_ihat_job_params) { { random_hash_of_things: [1,2,3] }}

      it "returns 422" do
        put :update, invalid_ihat_job_params
        expect(response.status).to eq(422)
      end
    end

  end
end
