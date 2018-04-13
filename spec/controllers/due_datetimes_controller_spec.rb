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

describe DueDatetimesController do
  let(:user) { FactoryGirl.build_stubbed(:user) }

  describe 'PUT #update' do
    let(:due_datetime) { FactoryGirl.create(:due_datetime, :in_5_days) }
    let(:reviewer_report) do
      rr = FactoryGirl.create(:reviewer_report, due_datetime: due_datetime)
      rr.schedule_events
      rr
    end

    subject(:do_request) do
      xhr :put, :update, format: :json, id: due_datetime.id, due_datetime: { due_at: due_datetime.due_at + 5.days }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :update the reviewer report' do
      before do
        stub_sign_in user
        allow(due_datetime).to receive(:due)
          .and_return reviewer_report

        allow(user).to receive(:can?)
          .with(:view, due_datetime.due.task)
          .and_return true

        allow(user).to receive(:can?)
          .with(:edit_due_date, due_datetime.due.task)
          .and_return true
      end

      it 'updates due date time' do
        do_request
        expect(response.status).to eq(200)
      end

      it 'responds with the rescheduled scheduled events' do
        scheduled_event_count = due_datetime.scheduled_events.count
        expect(scheduled_event_count).to be > 0
        do_request
        data = JSON.parse(response.body)
        expect(data["scheduled_events"].count).to eq scheduled_event_count
      end
    end
  end
end
