require 'rails_helper'

describe DueDatetimeController do
  let(:user) { FactoryGirl.build_stubbed(:user) }

  describe 'PUT #update' do
    let(:due_datetime) { FactoryGirl.create(:due_datetime, :in_5_days) }
    let(:reviewer_report) { FactoryGirl.create(:reviewer_report, due_datetime: due_datetime) }

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
        FactoryGirl.create :feature_flag, name: "REVIEW_DUE_DATE"
        FactoryGirl.create :feature_flag, name: "REVIEW_DUE_AT"
        do_request
        expect(response.status).to eq(200)
      end
    end
  end
end
