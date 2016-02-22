require 'rails_helper'

require 'rails_helper'

describe VersionedTextsController do
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :with_integration_journal,
      :with_tasks,
      creator: user
    )
  end
  let(:user) { FactoryGirl.create(:user) }
  # this will have been automagically created by setting the paper
  # body
  let(:versioned_text) { VersionedText.where(paper: paper).first! }

  before { sign_in user }

  describe "GET 'show'" do
    let(:request) { get :show, id: versioned_text.id, format: :json }
    let(:versioned_text_data) do
      JSON.parse(request.body)['versioned_text']
    end

    it 'succeeds' do
      expect(request).to be_success
    end

    it 'returns a version' do
      expected_keys = %w(
        id
        text
        updated_at
        paper_id
        major_version
        minor_version
      )
      expect(versioned_text_data.keys).to eq(expected_keys)
    end
  end
end
