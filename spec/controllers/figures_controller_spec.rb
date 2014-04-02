require 'spec_helper'

describe FiguresController do
  let(:permitted_params) { [:attachment, attachment: []] }

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
    let(:paper) { Paper.create! short_title: 'Paper with attachment', journal: Journal.create! }

    subject(:do_request) do
      post :create, paper_id: paper.to_param, figure: { attachment: fixture_file_upload('yeti.tiff') }
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

    context "when the attachments are in an array" do
      subject(:do_request) do
        post :create, paper_id: paper.to_param, figure: { attachment: [fixture_file_upload('yeti.tiff'), fixture_file_upload('yeti.jpg')] }
      end

      it "saves each attachment to this paper" do
        expect { do_request }.to change(Figure, :count).by(2)
        expect(Figure.last.paper).to eq paper
      end
    end

    context "when it's an AJAX request" do
      subject(:do_request) do
        post :create, paper_id: paper.to_param, figure: { attachment: fixture_file_upload('yeti.tiff') }, format: :json
      end

      it "responds with a JSON array of figure data" do
        do_request
        figure = Figure.last
        expect(JSON.parse(response.body)).to eq(
          {
            figures: [
              { filename: 'yeti.tiff',
                alt: 'Yeti',
                src: figure.attachment.url,
                id: figure.id }
            ]
          }.with_indifferent_access
        )
      end
    end
  end
end
