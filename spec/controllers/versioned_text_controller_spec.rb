require 'rails_helper'

require 'rails_helper'

describe VersionedTextsController, focus: true do
  let(:paper) { FactoryGirl.create(:paper, :with_tasks, creator: user) }
  let(:versioned_text) { FactoryGirl.create(:versioned_text, paper: paper) }
  let(:user) { create(:user, tasks: []) }

  before { sign_in user }

  describe "GET 'show'" do
    let(:request) { get :show, id: versioned_text.id, format: :json }
    let(:versioned_text_data) do
      JSON.parse(request.body)['versioned_text']
    end

    it "succeeds" do
      expect(request).to be_success
    end

    it "returns a version" do
      expected_keys = [
        "id",
        "text",
        "created_at",
        "version_string",
        "paper_id"
      ]
      expect(versioned_text_data.keys).to eq(expected_keys)
    end
  end
end
