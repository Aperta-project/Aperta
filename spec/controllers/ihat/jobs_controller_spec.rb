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
