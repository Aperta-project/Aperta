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

describe AffiliationsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:user_id) { other_user.id }

  it "returns a list of the institution names" do
    stub_sign_in user
    get :index, query: "Harvard"
    institution_names = res_body['institutions'].map { |i| i['name'] }
    expect(institution_names).to include('Harvard University')
  end

  describe '#create' do
    subject(:do_request) do
      post :create, format: 'json', affiliation: { name: "new", email: "email@example.com", user_id: user_id }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'signed in with permissions' do
      before do
        stub_sign_in user
        allow_any_instance_of(AffiliationsController).to receive(:requires_user_can).with(:manage_users, Journal) { true }
      end

      it "creates a new affiliate" do
        user_id = user.id
        expect { do_request }.to change { Affiliation.count }.by(1)
      end

      it "correctly sets a new affiliate email address" do
        user_id = user.id
        do_request
        expect(Affiliation.find_by(name: "new").email).to eq("email@example.com")
      end
    end

    context 'signed in without permissions' do
      let(:other_user) { FactoryGirl.create(:user) }
      let(:user_id) { other_user.id }

      before do
        stub_sign_in user
      end

      it_behaves_like 'a forbidden json request'
    end end

  describe '#destroy' do
    let!(:affiliation) { FactoryGirl.create(:affiliation, user: user) }
    subject(:do_request) do
      delete :destroy, id: affiliation.id
    end

    it_behaves_like "when the user is not signed in"

    it 'destroys an existing affiliation' do
      stub_sign_in user
      allow_any_instance_of(AffiliationsController).to receive(:requires_user_can).with(:manage_users, Journal) { true }
      expect do
        do_request
      end.to change { Affiliation.count }.by(-1)
    end
  end

  describe '#for_user' do
    subject(:do_request) do
      get :for_user, format: 'json', user_id: user_id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'signed in without permissions' do
      before do
        stub_sign_in user
      end

      it_behaves_like "a forbidden json request"
    end

    context 'signed in with permissions' do
      let!(:affiliation) { FactoryGirl.create(:affiliation, user: other_user) }

      before do
        stub_sign_in user
        allow_any_instance_of(AffiliationsController).to receive(:requires_user_can).with(:manage_users, Journal) { true }
      end

      it 'succeeds in responding' do
        do_request
        expect(response.status).to eq(200)
        expect(res_body).to include('affiliations')
      end
    end
  end
end
