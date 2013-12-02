require 'spec_helper'

describe FiguresController do
  let(:permitted_params) { [:attachment] }

  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  before { sign_in user }

  describe "POST 'create'" do
    let(:paper) { Paper.create! short_title: 'Paper with attachment' }

    subject(:do_request) do
      post :create, paper_id: paper.to_param, figure: { attachment: 'yeti.tiff' }
    end

    it_behaves_like "when the user is not signed in"

    it_behaves_like "a controller enforcing strong parameters" do
      let(:model_identifier) { :figure }
      let(:params_paper_id) { paper.to_param }
      let(:expected_params) { permitted_params }
    end

    it "saves the attachment to this paper" do
      expect { do_request }.to change(Figure, :count).by(1)
      expect(Figure.last.paper).to eq paper
    end

    it "redirects to paper's edit page" do
      do_request
      expect(response).to redirect_to edit_paper_path(paper)
    end
  end
end
