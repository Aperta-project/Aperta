require 'rails_helper'

describe DecisionAttachmentsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:decision) { FactoryGirl.create(:decision, paper: paper) }

  describe '#index' do
    let!(:decision_attachment) { FactoryGirl.create(:decision_attachment, owner: decision) }

    subject(:do_request) do
      get :index, format: :json, decision_id: decision.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :view the decision attachment' do
      before do
        stub_sign_in user
      end

      it 'it includes the decision attachment on the json' do
        allow(user).to receive(:can?)
          .with(:view, decision)
          .and_return true

        do_request

        data = res_body.with_indifferent_access
        expect(data).to have_key(:attachments)
        expect(res_body['attachments'][0]['id']).to eq(decision_attachment.id)
      end
    end
  end

  describe "#show" do
    let!(:decision_attachment) { FactoryGirl.create(:decision_attachment, owner: decision) }
    let!(:task) do
      FactoryGirl.create(
        :revise_task,
        :with_loaded_card,
        completed: true,
        paper: paper
      )
    end

    subject(:do_request) do
      get :show, format: :json, id: decision.id
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :view the decision attachment' do
      before do
        stub_sign_in user
      end

      it 'it includes the decision attachment on the json' do
        allow(user).to receive(:can?)
          .with(:view, decision)
          .and_return true

        do_request

        data = res_body.with_indifferent_access
        expect(data).to have_key("decision-attachment")
        expect(res_body['decision-attachment']['id']).to eq(decision_attachment.id)
      end
    end
  end

  describe "#update_attachment" do
    let!(:decision_attachment) { FactoryGirl.create(:decision_attachment, owner: decision) }
    let!(:task) do
      FactoryGirl.create(
        :revise_task,
        :with_loaded_card,
        completed: true,
        paper: paper
      )
    end
    let(:url) { Faker::Internet.url('example.com') }

    subject(:do_request) do
      put :update_attachment,
          format: :json,
          decision_id: decision.id,
          id: decision_attachment.id,
          url: url
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is authorized to :view the decision attachment' do
      before do
        stub_sign_in user
      end

      it 'it updates' do
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true

        expect(DownloadAttachmentWorker).to receive(:perform_async)
          .with(decision_attachment.id, url, user.id)

        do_request

        data = res_body.with_indifferent_access
        expect(data).to have_key("attachment")
        expect(res_body['attachment']['id']).to eq(decision_attachment.id)
      end
    end
  end
end
