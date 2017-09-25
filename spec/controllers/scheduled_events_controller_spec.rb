require 'rails_helper'

describe ScheduledEventsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "PUT /update (passive)" do
    let(:scheduled_event_active) { FactoryGirl.create(:scheduled_event, dispatch_at: DateTime.now.utc + 2.days) }
    subject(:do_request) { put :update, id: scheduled_event_active.id, state: 'passive', format: :json }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before { stub_sign_in user }

      it 'returns updates event state to passive' do
        do_request
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['scheduled_event']['state']).to eq 'passive'
      end
    end
  end

  describe "PUT /update (active)" do
    let(:scheduled_event_passive) { FactoryGirl.create(:scheduled_event, :passive, dispatch_at: DateTime.now.utc + 2.days) }
    subject(:do_request) { get :update, id: scheduled_event_passive.id, state: 'active', format: :json }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authenticated' do
      before { stub_sign_in user }

      it 'returns updates event state to active' do
        do_request
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['scheduled_event']['state']).to eq 'active'
      end
    end
  end

end
