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
        FactoryGirl.create :feature_flag, name: "REVIEW_DUE_DATE"
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
        expect(res_body.keys).to include 'reviewer_reports'
      end
    end
  end

  describe 'PUT #update' do
    let(:due_datetime) { FactoryGirl.create(:due_datetime, :in_5_days) }
    let(:reviewer_report) do
      FactoryGirl.create(:reviewer_report,
                         due_datetime: due_datetime)
    end

    subject(:do_request) do
      xhr :put, :update, format: :json, id: reviewer_report.id, reviewer_report: { task_id: reviewer_report.task.id }
    end

    subject(:change_due_date) do
      xhr :put, :update, format: :json,
                         id: reviewer_report.id,
                         reviewer_report: {
                           task_id: reviewer_report.task.id,
                           due_at: reviewer_report.due_at + 5.days
                         }
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

      it 'returns a 204' do
        FactoryGirl.create :feature_flag, name: "REVIEW_DUE_DATE"
        FactoryGirl.create :feature_flag, name: "REVIEW_DUE_AT"
        do_request
        expect(response.status).to eq(204)
      end

      context 'and the user updates the due datetime' do
        it 'returns a 200' do
          FactoryGirl.create :feature_flag, name: "REVIEW_DUE_DATE"
          FactoryGirl.create :feature_flag, name: "REVIEW_DUE_AT"
          change_due_date
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
