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
# rubocop:disable Metrics/BlockLength
describe ScheduledEventsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task, title: 'Dueable Task') }

  describe "PUT /update (passive)" do
    let(:scheduled_event_active) { FactoryGirl.create(:scheduled_event, dispatch_at: DateTime.now.utc + 2.days) }
    subject(:do_request) { put :update, id: scheduled_event_active.id, scheduled_event: { state: 'passive' }, format: :json }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before do
        stub_sign_in user
        expect(ScheduledEvent).to receive(:find).and_return(scheduled_event_active)
        expect(scheduled_event_active).to receive_message_chain(:due_datetime, :due).and_return(task)
      end
      it_behaves_like "a forbidden json request"

      it 'returns updates event state to passive' do
        allow(scheduled_event_active).to receive_message_chain(:due_datetime, :due).and_return(task)
        expect(user).to receive(:can?).with(:edit, task).and_return(true)
        do_request
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['scheduled_event']['state']).to eq 'passive'
      end
    end
  end

  describe "PUT /update (active)" do
    let(:scheduled_event_passive) { FactoryGirl.create(:scheduled_event, :passive, dispatch_at: DateTime.now.utc + 2.days) }
    subject(:do_request) { get :update, id: scheduled_event_passive.id, scheduled_event: { state: 'active' }, format: :json }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before do
        stub_sign_in user
        expect(ScheduledEvent).to receive(:find).and_return(scheduled_event_passive)
        expect(scheduled_event_passive).to receive_message_chain(:due_datetime, :due).and_return(task)
      end

      it_behaves_like "a forbidden json request"

      it 'returns updates event state to active' do
        expect(user).to receive(:can?).with(:edit, task).and_return(true)
        do_request
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['scheduled_event']['state']).to eq 'active'
      end
    end
  end
end
