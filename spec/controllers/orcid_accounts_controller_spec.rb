require 'rails_helper'

describe OrcidAccountsController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }

  describe "#show" do
    subject(:do_request) do
      get :show, id: orcid_account.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      context 'when ORCID_CONNECT_ENABLED is true' do
        around do |example|
          ClimateControl.modify(ORCID_CONNECT_ENABLED: 'true') do
            example.run
          end
        end

        it "calls the orcid account's serializer when rendering JSON" do
          do_request
          serializer = orcid_account.active_model_serializer.new(orcid_account, scope: orcid_account)
          expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
        end

        it { is_expected.to responds_with(200) }
      end

      context 'when ORCID_CONNECT_ENABLED is false' do
        around do |example|
          ClimateControl.modify(ORCID_CONNECT_ENABLED: 'false') do
            example.run
          end
        end

        it { is_expected.to responds_with(404) }
      end
    end
  end

  describe "#clear" do
    subject(:do_request) do
      get :clear, id: orcid_account.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in with remove_orcid permission' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?).with(:remove_orcid, Journal).and_return(true)
      end

      context 'when ORCID_CONNECT_ENABLED is true' do
        around do |example|
          ClimateControl.modify(ORCID_CONNECT_ENABLED: 'true') do
            example.run
          end
        end

        it "calls orcid_account.reset!" do
          allow(OrcidAccount).to receive(:find).with(orcid_account.to_param).and_return(orcid_account)
          expect(orcid_account).to receive(:reset!)
          do_request
        end

        it "calls the orcid account's serializer when rendering JSON" do
          do_request
          serializer = orcid_account.active_model_serializer.new(orcid_account, scope: orcid_account)
          expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
        end
      end

      context 'when ORCID_CONNECT_ENABLED is false' do
        around do |example|
          ClimateControl.modify(ORCID_CONNECT_ENABLED: 'false') do
            example.run
          end
        end

        it { is_expected.to responds_with(404) }
      end
    end

    context 'when the user does not have remove_orcid permission' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?).with(:remove_orcid, Journal).and_return(false)
      end

      context 'when ORCID_CONNECT_ENABLED is true' do
        around do |example|
          ClimateControl.modify(ORCID_CONNECT_ENABLED: 'true') do
            example.run
          end
        end

        it 'is not authorized' do
          do_request
          expect(response.status).to eq(403)
        end
      end

      context 'when ORCID_CONNECT_ENABLED is false' do
        around do |example|
          ClimateControl.modify(ORCID_CONNECT_ENABLED: 'false') do
            example.run
          end
        end

        it { is_expected.to responds_with(404) }
      end
    end
  end
end
