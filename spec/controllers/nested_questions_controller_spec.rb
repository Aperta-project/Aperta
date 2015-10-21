require 'rails_helper'

describe NestedQuestionsController do
  let(:user) { create :user, :site_admin }

  before do
    sign_in user
  end

  describe "#index" do
    let!(:questions) { [question1, question2] }
    let(:question1) { FactoryGirl.create(:nested_question, owner_type: "MyQuestionType", owner_id: nil) }
    let(:question2) { FactoryGirl.create(:nested_question, owner_type: "MyQuestionType", owner_id: nil) }

    def do_request(params={})
      get(:index, { type: "MyQuestion" }.merge(params), format: :json)
    end

    before do
      allow(NestedQuestion).to receive(:lookup_owner_type).with("MyQuestion").and_return "MyQuestionType"
    end

    it "responds with a list of questions for the given :type" do
      do_request
      json = JSON.parse(response.body)

      expected_ids = questions.map(&:id).sort
      actual_ids = json.fetch("nested_questions", []).map { |hsh| hsh["id"] }.sort

      expect(actual_ids).to eq(expected_ids)
    end

    it "responds with 200 OK" do
      do_request
      expect(response.status).to eq(200)
    end

    it_behaves_like "when the user is not signed in"
  end
end
