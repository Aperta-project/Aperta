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

describe TahiStandardTasks::ExportDeliveriesController do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, journal: journal, publishing_state: 'accepted' }
  let(:task) { FactoryGirl.create :send_to_apex_task, paper: paper }

  subject(:do_request) do
    post :create, format: :json, export_delivery: { task_id: task.to_param }
  end

  context "the current user can send to apex" do
    before do
      stub_sign_in user
      allow(user).to receive(:can?)
        .with(:send_to_apex, paper)
        .and_return true
    end

    it "creates an apex delivery" do
      expect do
        do_request
        expect(response).to have_http_status(200)
      end.to change { TahiStandardTasks::ExportDelivery.count }.by 1
    end

    it "saves the destination on the apex delivery" do
      do_request
      expect(response.status).to eq(200)
      expect(res_body['export_delivery']['destination']).to eq('apex')
    end
  end

  context "the current user can't send to apex" do
    before do
      stub_sign_in user
      allow(user).to receive(:can?)
        .with(:send_to_apex, paper)
        .and_return false
    end

    it "fails and returns a 403" do
      expect do
        do_request
        expect(response).to have_http_status(403)
      end.to change { TahiStandardTasks::ExportDelivery.count }.by 0
    end
  end
end
