require 'spec_helper'

describe Api::JournalsController do
  describe "GET 'index'" do
    let!(:journal1) { create :journal }
    let!(:journal2) { create :journal }

    it 'returns a list of journals in the system' do
      get api_journals_path
      data = JSON.parse response.body
      expect(data).to eq (
        {
          journals: [
            { id: journal1.id, name: journal1.name },
            { id: journal2.id, name: journal2.name }
          ]
        }.with_indifferent_access
      )
    end
  end
end
