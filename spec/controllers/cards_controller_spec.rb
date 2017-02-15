require "rails_helper"

describe CardsController do
  subject(:do_request) do
    get :show, format: 'json', owner_type: object.class.name.underscore, owner_id: object.id
  end

  describe "#show" do
    let(:user) { create :user, :site_admin }

    before do
      stub_sign_in user
    end

    context "resource is answerable" do
      let(:card) { FactoryGirl.create(:card) }
      let(:object) { FactoryGirl.create(:cover_letter_task, card: card) }

      it "returns a serialized card" do
        do_request
        expect(response.status).to eq(200)
        expect(res_body).to include("card")
      end
    end

    context "resource is not answerable" do
      let(:object) { FactoryGirl.create(:user) }

      it "returns a 422" do
        do_request
        expect(response.status).to eq(422)
      end
    end
  end

  context "authentication" do
    let(:card) { FactoryGirl.create(:card) }
    let(:object) { FactoryGirl.create(:cover_letter_task, card: card) }

    it_behaves_like 'an unauthenticated json request'
  end
end
