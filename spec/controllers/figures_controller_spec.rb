require 'spec_helper'

describe FiguresController do
  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  before do
    sign_in user
  end

  describe "destroying the figure" do
    let(:paper) { user.papers.create! short_title: 'Paper with attachment', journal: Journal.create! }
    subject(:do_request) { delete :destroy, id: paper.figures.last.id, paper_id: paper.id }
    before(:each) do
      paper.figures.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
    end

    it "destroys the figure record" do
      expect {
        do_request
      }.to change{Figure.count}.by -1
    end
  end

  describe "Unauthorized Request" do
    let(:paper) { Paper.create! short_title: 'Paper with attachment', journal: Journal.create! }

    subject(:do_request) do
      post :create, paper_id: paper.to_param, figure: { attachment: fixture_file_upload('yeti.tiff', 'image/tiff') }
    end

    it "will not allow access" do
      do_request
      expect(response.status).to eq(404)
    end
  end

  describe "POST 'create'" do
    let(:paper) { Paper.create! short_title: 'Paper with attachment', journal: Journal.create!, user: user }

    subject(:do_request) do
      post :create, paper_id: paper.to_param, figure: { attachment: fixture_file_upload('yeti.tiff', "image/tiff") }
    end

    it_behaves_like "when the user is not signed in"

    it "saves the attachment to this paper" do
      expect { do_request }.to change(Figure, :count).by(1)
      expect(Figure.last.paper).to eq paper
    end

    it "redirects to paper's edit page" do
      do_request
      expect(response).to redirect_to edit_paper_path(paper)
    end

    context "validating the filetype" do
      it "rejects bad filetypes" do
        expect {
          post :create, paper_id: paper.to_param, figure: { attachment: fixture_file_upload('about_turtles.docx') }
        }.to change{Figure.count}.by 0
      end
    end

    context "when the attachments are in an array" do
      subject(:do_request) do
        post :create, paper_id: paper.to_param, figure: { attachment: [fixture_file_upload('yeti.tiff', 'image/tiff'), fixture_file_upload('yeti.jpg', 'image/jpg')] }
      end

      it "saves each attachment to this paper" do
        expect { do_request }.to change(Figure, :count).by(2)
        expect(Figure.last.paper).to eq paper
      end
    end

    context "when it's an AJAX request" do
      subject(:do_request) do
        post :create, paper_id: paper.to_param, figure: { attachment: fixture_file_upload('yeti.tiff', 'image/tiff') }, format: :json
      end

      it "responds with a JSON array of figure data" do
        do_request
        figure = Figure.last
        expect(JSON.parse(response.body)).to eq(
          {
            figures: [
              { id: figure.id,
                filename: "yeti.tiff",
                alt: "Yeti",
                src: "/uploads/paper/1/figure/attachment/1/yeti.tiff",
                title: "yeti.tiff",
                caption: nil,
                paper_id: paper.id }
            ]
          }.with_indifferent_access
        )
      end
    end
  end

  describe "PUT 'update'" do
    let(:paper) { user.papers.create! short_title: 'Paper with attachment', journal: Journal.create! }
    subject(:do_request) { patch :update, id: paper.figures.last.id, paper_id: paper.id, figure: {title: "new title", caption: "new caption"} }
    before(:each) do
      paper.figures.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
    end

    it "allows updates for title and caption" do
      do_request

      figure = paper.figures.last
      expect(figure.caption).to eq("new caption")
      expect(figure.title).to eq("new title")
    end
  end
end
