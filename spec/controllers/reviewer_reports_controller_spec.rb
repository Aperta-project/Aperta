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

describe ReviewerReportsController do
  let(:user) { FactoryGirl.build_stubbed(:user) }

  describe 'GET #show' do
    let(:reviewer_report) { FactoryGirl.create(:reviewer_report) }

    subject(:do_request) do
      xhr :get, :show, format: :json, id: reviewer_report.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :edit the reviewer report task' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, reviewer_report.task)
          .and_return true

        allow(user).to receive(:can?)
          .with(:view, reviewer_report.task)
          .and_return true
      end

      it 'renders the reviewer report' do
        do_request
        expect(response.status).to eq(200)
        expect(res_body.keys).to include 'reviewer_report'
      end
    end
  end

  describe 'PUT #update' do
    let(:reviewer_report) { FactoryGirl.create(:reviewer_report) }

    subject(:do_request) do
      xhr :put, :update, format: :json, id: reviewer_report.id, reviewer_report: { task_id: reviewer_report.task.id }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :update the reviewer report' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, reviewer_report.task)
          .and_return true

        allow(user).to receive(:can?)
          .with(:view, reviewer_report.task)
          .and_return true
      end

      it 'updates a reviewer report' do
        do_request
        expect(response.status).to eq(204)
      end
    end
  end
end
