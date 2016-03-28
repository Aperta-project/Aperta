require 'rails_helper'

describe TahiStandardTasks::FundersController do
  routes { TahiStandardTasks::Engine.routes }

  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:task) { FactoryGirl.create(:financial_disclosure_task) }
  let(:additional_comments) { "Darmok and Jalad at Tanagra" }

  describe '#create' do
    subject(:do_request) do
      post :create,
           format: :json,
           funder: {
             task_id: task.id,
             name: "Batelle",
             additional_comments: additional_comments
           }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:edit, task)
          .and_return(true)
      end

      it { is_expected.to responds_with(201) }

      it 'creates a funder' do
        expect { do_request }.to change { TahiStandardTasks::Funder.count }.by 1
        task = TahiStandardTasks::Funder.last
        expect(task.additional_comments).to eq additional_comments
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:edit, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#update' do
    let!(:funder) { FactoryGirl.create(:funder, task: task) }

    subject(:do_request) do
      put :update, format: :json, id: funder.id,
                   funder: { name: 'Galactic Empire' }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:edit, task)
          .and_return(true)
      end

      it 'patches the funder' do
        do_request
        expect(response).to be_success
        expect(funder.reload.name).to eq('Galactic Empire')
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:edit, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#destroy' do
    let!(:funder) { FactoryGirl.create(:funder, task: task) }

    subject(:do_request) do
      delete :destroy, format: :json, id: funder.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:edit, task)
          .and_return(true)
      end

      it 'eliminates the funder' do
        funder_count = TahiStandardTasks::Funder.count
        do_request
        expect(TahiStandardTasks::Funder.count).to eq(funder_count - 1)
        expect(response).to be_success
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?).with(:edit, task)
          .and_return(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
