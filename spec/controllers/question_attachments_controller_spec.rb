require 'rails_helper'

describe QuestionAttachmentsController do

  expect_policy_enforcement

  let(:user) { create :user, :site_admin }

  before do
    sign_in user
  end

  describe "#show" do
    let!(:question_attachment) { FactoryGirl.create(:question_attachment) }
    subject(:do_request) do
      get :show, format: :json, id: question_attachment.id
    end

    it "succeeds" do
      do_request
      expect(response.status).to be(200)
    end

    it "returns the question attachement" do
      do_request
      expect(res_body['question_attachment']['id']).to be(question_attachment.id)
    end
  end

  describe "#destroy" do
    let!(:question_attachment) { FactoryGirl.create(:question_attachment) }

    it "destroys the question" do
      expect {
        put :destroy, format: :json, id: question_attachment.id
      }.to change { QuestionAttachment.count }.by(-1)
    end
  end

end
