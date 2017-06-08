require 'rails_helper'

describe AnswersController do
  let(:user) { FactoryGirl.create :user }
  let(:card_content) { FactoryGirl.create(:card_content) }
  let(:owner) { FactoryGirl.create(:ad_hoc_task) }

  describe '#update' do
    let!(:answer) { FactoryGirl.create(:answer, value: 'initial', card_content: card_content, owner: owner) }
    let(:card_content) { FactoryGirl.create(:card_content) }

    subject(:do_request) do
      put_params = {
        format: 'json',
        id: answer.to_param,
        card_content_id: card_content.to_param,
        answer: {
          value: 'after',
          owner_id: owner.id,
          owner_type: owner.type
        }
      }
      put(:update, put_params)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user does has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
                         .with(:edit, owner)
                         .and_return true
      end

      it 'updates the answer for the question' do
        expect do
          do_request
        end.to_not change(Answer, :count)

        json = JSON.parse(response.body)
        expect(json['answer']['value']).to_not be_present

        answer.reload
        expect(answer.value).to eq('after')
      end
    end
  end
end
