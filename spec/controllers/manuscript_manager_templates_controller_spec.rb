require 'rails_helper'

describe ManuscriptManagerTemplatesController do
  expect_policy_enforcement

  def validate_template_json(test_params)
    template = res_body['manuscript_manager_template']

    test_params.each do |k, v|
      expect(template[k.to_s]).to eq(v)
    end
  end

  let(:admin) { FactoryGirl.create(:user, :site_admin) }
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
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
      expect(res_body).to have_key('manuscript_manager_template')
    end
  end

  describe "PUT update" do
    let(:template_params) {
      [ [{type: 'text', value: 'text here'}] ]
    }

    let(:new_params) { {
      name: 'New name',
      paper_type: 'new type',
      journal_id: journal.id,
      phase_templates: [
        manuscript_manager_template_id: mmt.id,
        name: 'Phase title',
        position: 1,
        task_templates: [
          journal_task_type_id: journal.id,
          title: 'Ad-hoc',
          template: template_params
        ]
      ]
    } }

    subject(:do_request) do
      put :update, {format: 'json', id: mmt.id,
                    manuscript_manager_template: new_params}
    end

    it "returns 200 with valid params" do
      do_request
      expect(response.status).to eq(200)
    end

    it "updates the model" do
      do_request
      mmt = ManuscriptManagerTemplate.last
      template = mmt.phase_templates.last.task_templates.last.template
      expect(mmt.paper_type).to eq(new_params[:paper_type])
      expect(template.to_json).to eq(template_params.to_json)
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
        expect(res_body).to have_key('errors')
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
