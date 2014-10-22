require 'spec_helper'

describe ManuscriptManagerTemplatesController do

  expect_policy_enforcement

  def validate_template_json(test_params)
    template = JSON.parse(response.body)['manuscript_manager_template']

    test_params.each do |k, v|
      expect(template[k.to_s]).to eq(v)
    end
  end

  let(:admin) { create :user, :site_admin }
  let(:journal) { create :journal }
  let(:mmt) { journal.manuscript_manager_templates.first }

  before do
    assign_journal_role journal, admin, :admin
    sign_in admin
  end

  describe 'POST create' do
    let(:new_params) { {paper_type: 'new type', journal_id: journal.id } }
    subject(:do_request) do
      post :create, format: 'json', manuscript_manager_template: new_params
    end

    it 'creates a new template and returns it as json' do
      do_request
      expect(response.status).to eq(201)

      validate_template_json(new_params)
    end
  end

  describe "GET show" do
    subject(:do_request) { get :show, {format: 'json', id: mmt.id } }

    it "renders the given template as json" do
      do_request
      expect(JSON.parse(response.body)).to have_key('manuscript_manager_template')
    end
  end

  describe "PUT update" do
    let(:new_params) { {name: 'New name', paper_type: 'new type', journal_id: journal.id} }

    subject(:do_request) do
      put :update, {format: 'json', id: mmt.id,
                    manuscript_manager_template: new_params}
    end

    it "returns 204 with valid params" do
      do_request
      expect(response.status).to eq(204)
    end

    it "updates the model" do
      do_request
      expect(ManuscriptManagerTemplate.last.paper_type).to eq(new_params[:paper_type])
    end

    context "with invalid params" do
      let(:new_params) { {paper_type: nil, template: {}} }
      it_behaves_like "a controller rendering an invalid model"
    end
  end

  describe "DELETE destroy" do
    subject(:do_request) { delete :destroy, {format: :json, id: mmt.id} }

    context "when a journal has one manuscript manager template" do
      it "returns an error" do
        expect(journal.manuscript_manager_templates.count).to eq 1
        do_request
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context "when a journal has multiple manuscript manager templates" do
      before do
        FactoryGirl.create(:manuscript_manager_template, journal: journal)
      end

      it "returns the deleted template as JSON" do
        expect(journal.manuscript_manager_templates.count).to be > 1
        do_request
        expect(response.status).to eq(204)
      end
    end

  end
end
