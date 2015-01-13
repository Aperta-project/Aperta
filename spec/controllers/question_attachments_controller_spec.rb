require 'rails_helper'

describe QuestionAttachmentsController do

  expect_policy_enforcement

  let(:user) { create :user, :site_admin }

  before do
    sign_in user
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
