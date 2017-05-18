require 'rails_helper'

describe CommentLooksController do
  let(:user) { FactoryGirl.create :user }
  let(:comment) { FactoryGirl.create :comment }

  describe '#index' do
    subject(:do_request) { get :index, format: :json }

    it_behaves_like "an unauthenticated json request"

    it "lists all the comment_looks for the user" do
      stub_sign_in(user)
      FactoryGirl.create_list :comment_look, 5, user: user, comment: comment
      do_request
      expect(response.status).to eq(200)
      expect(res_body['comment_looks'].count).to eq(5)
    end
  end

  describe '#show' do
    let!(:comment_look) { FactoryGirl.create :comment_look, user: user, comment: comment }
    subject(:do_request) { get :show, format: :json, id: comment_look.id }

    it_behaves_like "an unauthenticated json request"

    it "returns the comment look" do
      stub_sign_in(user)
      do_request
      expect(response.status).to eq(200)
      expect(res_body['comment_look']['id']).to eq(comment_look.id)
    end
  end

  describe '#destroy' do
    let!(:comment_look) { FactoryGirl.create :comment_look, user: user, comment: comment }
    subject(:do_request) { delete :destroy, format: :json, id: comment_look.id }

    it_behaves_like "an unauthenticated json request"

    it "remove the comment_look" do
      stub_sign_in(user)
      expect do
        do_request
      end.to change { CommentLook.all.count }.from(1).to(0)
      expect(response.status).to eq(204)
    end
  end
end
