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
      flags = res_body[:feature_flags]
      expect(flags.length).to eq(2)
      expect(flags[0][:active]).to eq(true)
      expect(flags[1][:active]).to eq(true)
    end
  end

  describe '#update' do
    subject(:do_request) do
      flag = { name: feature_flag1.name, active: false }
      put :update, feature_flag: flag, id: feature_flag1.id, format: :json
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

      it 'changes updates the active value' do
        expect { do_request }.to change { feature_flag1.reload.active }.from(true).to(false)
        is_expected.to responds_with(204)
      end
    end
  end
end
