require 'rails_helper'

describe ManuscriptManagerTemplatesController do
  def validate_template_json(test_params)
    template = res_body['manuscript_manager_template']

    test_params.each do |k, v|
      expect(template[k.to_s]).to eq(v)
    end
  end

  let(:journal) { FactoryGirl.create(:journal) }
  let(:user) { FactoryGirl.build(:user) }

  describe 'POST create' do
    subject(:do_request) do
      post :create, format: 'json', manuscript_manager_template: new_params
    end
    let(:new_params) do
      {
        paper_type: 'new type',
        journal_id: journal.id,
        uses_research_article_reviewer_report: true
      }
    end

    it_behaves_like "an unauthenticated json request"

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, journal)
          .and_return true
      end

      it "responds with 201 CREATED" do
        do_request
        expect(response.status).to eq(201)
      end

      it 'creates a new ManuscriptManagerTemplate and returns it as json' do
        expect do
          do_request
        end.to change { ManuscriptManagerTemplate.count }.by(1)

        mmt = ManuscriptManagerTemplate.last
        expect(mmt.paper_type).to eq('new type')
        expect(mmt.journal_id).to eq(journal.id)
        expect(mmt.uses_research_article_reviewer_report).to be(true)

        validate_template_json(new_params)
      end
    end

    context "when the user is unauthorized" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, journal)
          .and_return false
      end

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end
    end
  end

  describe "GET show" do
    subject(:do_request) { get :show, {format: 'json', id: mmt.id } }
    let(:mmt) { journal.manuscript_manager_templates.first }

    it_behaves_like "an unauthenticated json request"

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, mmt.journal)
          .and_return true
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end

      it "renders the given template as json" do
        do_request
        expect(res_body).to have_key('manuscript_manager_template')
      end
    end

    context "when the user is unauthorized" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, mmt.journal)
          .and_return false
      end

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end
    end
  end

  describe "PUT update" do
    subject(:do_request) do
      put \
        :update,
        format: 'json',
        id: mmt.id,
        manuscript_manager_template: new_params
    end
    let(:mmt) do
      FactoryGirl.create \
        :manuscript_manager_template,
        uses_research_article_reviewer_report: false,
        journal: journal
    end
    let(:new_params) do
      {
        name: 'New name',
        paper_type: 'new type',
        journal_id: journal.id,
        uses_research_article_reviewer_report: true,
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
      }
    end
    let(:template_params) do
      [ [{type: 'text', value: 'text here'}] ]
    end

    it_behaves_like "an unauthenticated json request"

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, mmt.journal)
          .and_return true
      end

      it "responds with 200 OK" do
        do_request
        expect(response.status).to eq(200)
      end

      it "updates the ManuscriptManagerTemplate" do
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

    context "when the user is unauthorized" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, mmt.journal)
          .and_return false
      end

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end
    end
  end

  describe "DELETE destroy" do
    let(:mmt) { journal.manuscript_manager_templates.first }
    subject(:do_request) { delete :destroy, { format: :json, id: mmt.id } }

    it_behaves_like "an unauthenticated json request"

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, mmt.journal)
          .and_return true
      end

      context "when a journal has one manuscript manager template" do
        it "returns an error" do
          expect(journal.manuscript_manager_templates.count).to eq 1
          do_request
          expect(res_body).to have_key('errors')
        end

        it "responds with 422 UNPROCESSABLE ENTITY" do
          do_request
          expect(response.status).to eq(422)
        end
      end

      context "when a journal has multiple manuscript manager templates" do
        before do
          FactoryGirl.create(:manuscript_manager_template, journal: journal)
        end

        it "deletes the ManuscriptManagerTemplate" do
          expect do
            do_request
          end.to change { ManuscriptManagerTemplate.exists?(mmt.id) }.to false
        end

        it "responds with 204 NO CONTENT" do
          do_request
          expect(response.status).to eq(204)
        end
      end
    end

    context "when the user is unauthorized" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, mmt.journal)
          .and_return false
      end

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end

      it "does not delete the ManuscriptManagerTemplate" do
        expect do
          do_request
        end.to_not change { ManuscriptManagerTemplate.count }
      end
    end
  end
end
