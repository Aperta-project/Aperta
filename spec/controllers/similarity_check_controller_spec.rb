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

describe SimilarityChecksController, type: :controller do
  let(:user) { create :user }

  describe "#create" do
    let!(:versioned_text) { create :versioned_text }
    let(:do_request) do
      get :create, format: :json, similarity_check: {
        versioned_text_id: versioned_text.to_param
      }
    end

    context "the user can perform a similarity check" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:perform_similarity_check, versioned_text.paper)
                         .and_return true
      end

      it "succeeds" do
        do_request
        expect(response).to be_success
      end

      it "creates a new SimilarityCheck record" do
        expect do
          do_request
        end.to change { SimilarityCheck.count }.by(1)
      end

      it "triggers the SimliarityCheck report to start" do
        expect_any_instance_of(SimilarityCheck).to receive(:start_report_async)
        do_request
      end
    end

    context "the user can't perform similarity checks" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:perform_similarity_check, versioned_text.paper)
                         .and_return false
      end

      it "fails with an HTTP 403" do
        do_request
        expect(response.status).to eq 403
      end

      it "does not create a SimilarityCheck record" do
        expect do
          do_request
        end.to_not change { SimilarityCheck.count }
      end
    end
  end

  describe "#report_view_only" do
    let(:similarity_check) { create :similarity_check, :report_complete }
    let(:paper) { similarity_check.versioned_text.paper }
    let(:do_request) do
      get :report_view_only, id: similarity_check.to_param
    end
    let(:fake_url) { Faker::Internet.url }
    let(:response_double) do
      double(Ithenticate::ReportResponse, view_only_url: fake_url)
    end

    before do
      allow_any_instance_of(Ithenticate::Api).to(
        receive(:get_report).with(
          id: similarity_check.ithenticate_report_id
        ).and_return(response_double)
      )
    end

    context "the user can perform a similarity check" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:perform_similarity_check, paper)
                         .and_return true
      end

      it "redirects to the view_only_url" do
        expect(do_request).to redirect_to(fake_url)
      end
    end

    context "the user can't perform a similarity check" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:perform_similarity_check, paper)
                         .and_return false
      end

      it "fails with an HTTP 403" do
        do_request
        expect(response.status).to eq 403
      end
    end
  end
end
