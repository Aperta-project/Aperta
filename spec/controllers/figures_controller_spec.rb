require 'rails_helper'

describe FiguresController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }

  authorize_policy(FiguresPolicy, true)

  before do
    paper.figures.create!
  end

  describe "#index" do
    let!(:figure1) { FactoryGirl.create(:figure, paper: paper) }
    let!(:figure2) { FactoryGirl.create(:figure, paper: paper) }

    subject(:do_request) do
      get :index, {
            format: 'json',
            paper_id: paper.to_param,
          }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is authenticated' do
      before { stub_sign_in user }

      it "returns the paper's figures" do
        do_request
        paper.reload
        expect(res_body['figures'].count).to eq(paper.figures.count)
        figure_ids_in_response = res_body['figures'].map { |data| data['id'] }
        expect(figure_ids_in_response).to contain_exactly(*paper.figure_ids)
      end
    end
  end

  describe '#destroy' do
    subject(:do_request) do
      delete(
        :destroy,
        id: paper.figures.last.id,
        paper_id: paper.id,
        format: 'json'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is authenticated' do
      before { stub_sign_in user }

      it "destroys the figure record" do
        expect {
          do_request
        }.to change{Figure.count}.by -1
      end
    end
  end

  describe "POST 'create'" do
    subject(:do_request) do
      post :create, format: "json", paper_id: paper.to_param, url: url
    end
    let(:url) { "http://someawesomeurl.com" }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is authenticated' do
      before { stub_sign_in user }

      it "causes the creation of the figure" do
        expect(DownloadFigureWorker).to receive(:perform_async)
        do_request
        expect(response).to be_success
      end
    end
  end

  describe "PUT 'update_attachment'" do
    subject(:do_request) do
      put :update_attachment, format: "json", id: figure.id, url: url
    end
    let(:url) { "http://someawesomeurl.com" }
    let(:figure) { paper.figures.create! }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is authenticated' do
      before { stub_sign_in user }

      it "calls DownloadFigureWorker" do
        expect(DownloadFigureWorker).to receive(:perform_async).with(figure.id, url)
        do_request
        expect(response).to be_success
      end
    end
  end

  describe "PUT 'update'" do
    subject(:do_request) do
      put(
        :update,
        id: paper.figures.last.id,
        paper_id: paper.id,
        figure: { title: "new title", caption: 'new caption' },
        format: :json
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is authenticated' do
      before { stub_sign_in user }

      it "allows updates for title and caption" do
        do_request

        figure = paper.figures.last.reload
        expect(figure.caption).to eq("new caption")
        expect(figure.title).to eq("new title")
      end
    end
  end
end
