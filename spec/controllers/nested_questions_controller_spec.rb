require 'rails_helper'

describe NestedQuestionsController do
  let(:user) { create :user, :site_admin }

  before do
    sign_in user
  end

  describe "#index" do
    let!(:questions) { [question1, question2] }
    let!(:card) { FactoryGirl.create(:card, :versioned, journal: nil, name: "My Card") }
    let(:card_version) { card.card_version(:latest) }
    let(:root) { card.content_root_for_version(1) }
    let(:question1) { FactoryGirl.build(:card_content, card_version: card_version).tap { |c| root.children << c } }
    let(:question2) { FactoryGirl.build(:card_content, card_version: card_version).tap { |c| root.children << c } }

    def do_request(params={})
      get(:index, { type: "My Card" }.merge(params), format: :json)
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
