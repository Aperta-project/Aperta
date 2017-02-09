require 'rails_helper'

describe FeatureFlagsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:feature_flag1) { FactoryGirl.create(:feature_flag) }
  let!(:feature_flag2) { FactoryGirl.create(:feature_flag) }

  describe '#index' do
    subject(:do_request) do
      get :index, format: :json
    end

    it 'responds with the list of feature flags' do
      do_request
      expect(res_body.keys.count).to eq(2)
      expect(res_body[feature_flag1.name]).to eq(true)
      expect(res_body[feature_flag2.name]).to eq(true)
    end
  end

  describe '#update' do
    subject(:do_request) do
      post :update,
        name: feature_flag1.name,
        feature_flag: { active: false },
        format: :json
    end

    context 'when the user has no access' do
      before do
        stub_sign_in user
        allow(user).to receive(:site_admin?).and_return(false)
      end
      it { is_expected.to responds_with(403) }
    end

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:site_admin?).and_return(true)
      end

      it { is_expected.to responds_with(201) }

      it 'changes updates the active value' do
        expect { do_request }.to change { feature_flag1.reload.active }.from(true).to(false)
      end
    end
  end
end
