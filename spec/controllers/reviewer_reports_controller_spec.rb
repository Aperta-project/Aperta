require 'rails_helper'

describe ReviewerReportsController do
  let(:user) { FactoryGirl.build(:user) }

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
      end

      it 'renders the reviewer report' do
        do_request
        expect(response.status).to eq(200)
        expect(res_body.keys).to include 'reviewer_reports'
      end
    end
  end

  describe 'POST #create' do
    let(:reviewer_report_task) { FactoryGirl.create(:reviewer_report_task) }

    subject(:do_request) do
      xhr :post, :create, format: :json, reviewer_report: { task_id: reviewer_report_task.id }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :create the reviewer report' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, reviewer_report_task)
          .and_return true
      end

      it 'creates a new reviewer report' do
        expect{
          do_request
        }.to change{ ReviewerReport.count }.from(0).to(1)
        expect(response.status).to eq(200)
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
      end

      it 'returns the reviewer report' do
        do_request
        expect(response.status).to eq(200)
        expect(res_body.keys).to include 'reviewer_reports'
      end
    end
  end

  describe 'DELETE #destroy' do


    let(:reviewer_report) { FactoryGirl.create(:reviewer_report) }

    subject(:do_request) do
      xhr :delete, :destroy, format: :json, id: reviewer_report.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :edit the reviewer report task' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, reviewer_report.task)
          .and_return true
      end

      it 'destroys the reviewer report' do
        expect{
          do_request
        }.to change{ ReviewerReport.count }.from(1).to(0)
        expect(response.status).to eq(200)
      end
    end

  end
end
