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

def correspondence_rbac(access)
  stub_sign_in user
  allow(user).to receive(:can?)
    .with(:manage_workflow, paper)
    .and_return access
end

def new_correspondence_params(paper)
  {
    sender: Faker::Internet.safe_email,
    recipients: Faker::Internet.safe_email,
    cc: Faker::Internet.safe_email,
    bcc: Faker::Internet.safe_email,
    date: DateTime.now.in_time_zone.as_json,
    sent_at: DateTime.now.in_time_zone.as_json,
    description: "A bleak description",
    subject: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraph,
    paper_id: paper.id
  }
end

describe CorrespondenceController do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  describe 'GET index' do
    subject(:do_request) do
      get :index, format: 'json',
                  paper_id: paper.id
    end

    context 'when user has access' do
      let!(:correspondence_one) do
        FactoryGirl.create(:correspondence, :as_external, paper: paper)
      end
      let!(:correspondence_two) do
        FactoryGirl.create(:correspondence, :as_external, paper: paper)
      end

      before do
        correspondence_rbac(true)
      end

      it "returns the paper's correspondences" do
        do_request
        expect(res_body['correspondence'].count).to eq(2)
        expect(res_body['correspondence'][0]['id']).to eq(correspondence_two.id)
      end

      it 'returns status code 200' do
        is_expected.to have_http_status(200)
      end
    end

    context "when user does not have access" do
      before do
        correspondence_rbac(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create,
                  format: 'json',
                  paper_id: paper.id,
                  correspondence: new_correspondence_params(paper)
    end

    context 'when user has access' do
      before do
        correspondence_rbac true
      end

      context 'when record is valid' do
        it 'creates a correspondence' do
          expect { do_request }.to change { Correspondence.count }.by 1
        end

        it 'creates adds a correspondence.created activity' do
          expect(Activity).to receive(:correspondence_created!)
          do_request
        end
      end
    end
  end

  describe 'PUT update' do
    before do
      correspondence_rbac true
    end

    subject(:do_request) do
      xhr :put, :update,
                format: :json,
                id: correspondence.id,
                paper_id: correspondence.paper.id,
                correspondence: { description: 'Updated description' }
    end

    context 'for external correspondence' do
      let(:correspondence) { FactoryGirl.create :correspondence, :as_external, paper: paper }

      it 'updates the correspondence' do
        expect do
          do_request
          expect(response.status).to eq 200
        end.to change { correspondence.reload.description }
          .from(correspondence.description).to 'Updated description'
      end
    end
  end

  context 'for automatically generated correspondence' do
    let(:correspondence) { FactoryGirl.create :correspondence, paper: paper }

    it 'does not update correspondence' do
      expect do
        do_request
        expect(response.status).to eq 204
      end
      expect(correspondence.reload.description)
        .to eq correspondence.description
    end
  end
end
