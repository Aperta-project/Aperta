require 'rails_helper'

describe CommentLooksController do
  include AuthorizationSpecHelper

  let(:user) { FactoryGirl.create :user }

  before { sign_in user }

  describe '#index' do
    it "throw an error if not logged" do
      sign_out user
      get :index, format: :json
      expect(response.status).to eq(401)
      expect(response.body).not_to include("comment_looks")
    end

    it "lists all the comment_looks for the user" do
      FactoryGirl.create_list :comment_look, 5, user: user
      get :index, format: :json
      expect(response.status).to eq(200)
      expect(res_body['comment_looks'].count).to eq(5)
    end
  end

  describe '#show' do
    let!(:comment_look) { FactoryGirl.create :comment_look, user: user }

    it "throw an error if not logged" do
      sign_out user
      get :show, format: :json, id: comment_look.id
      expect(response.status).to eq(401)
      expect(response.body).not_to include("comment_look")
    end

    it "returns the comment look" do
      get :show, format: :json, id: comment_look.id
      expect(response.status).to eq(200)
      expect(res_body['comment_look']['id']).to eq(comment_look.id)
    end
  end

  describe '#destroy' do
    let!(:comment_look) { FactoryGirl.create :comment_look, user: user }

    it "throw an error if not logged" do
      sign_out user
      delete :destroy, id: comment_look.id, format: :json
      expect(response.status).to eq(401)
      expect(response.body).not_to include("comment_look")
    end

    it "remove the comment_look" do
      expect do
        delete :destroy, id: comment_look.id, format: :json
      end.to change { CommentLook.all.count }.from(1).to(0)
      expect(response.status).to eq(204)
    end
  end
end
