require 'rails_helper'

describe FiguresController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.build_stubbed(:paper) }
  let(:figure) { FactoryGirl.create(:figure, paper: paper) }

  describe "#index" do
    let(:paper) { FactoryGirl.create(:paper) }
    let!(:figure1) { FactoryGirl.create(:figure, owner: paper) }
    let!(:figure2) { FactoryGirl.create(:figure, owner: paper) }

    subject(:do_request) do
      get :index, format: 'json',
                  paper_id: paper.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
      end

      it "returns the paper's figures" do
        do_request
        paper.reload
        expect(res_body['figures'].count).to eq(paper.figures.count)
        figure_ids_in_response = res_body['figures'].map { |data| data['id'] }
        expect(figure_ids_in_response).to contain_exactly(*paper.figure_ids)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe '#destroy' do
    let(:paper) { FactoryGirl.create(:paper) }
    let!(:figure1) { FactoryGirl.create(:figure, owner: paper) }
    subject(:do_request) do
      delete(
        :destroy,
        id: figure1.id.to_param,
        paper_id: paper.id.to_param,
        format: 'json'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
      end

      it 'destroys the figure record' do
        expect do
          paper.reload
          do_request
        end.to change { Figure.count }.by(-1)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "POST 'create'" do
    let(:paper) { FactoryGirl.create(:paper) }
    subject(:do_request) do
      post :create, format: "json", paper_id: paper.to_param, url: url
    end
    let(:url) { "http://someawesomeurl.com" }

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
        allow(DownloadAttachmentWorker).to receive(:download_attachment)
      end

      it "creates a figures" do
        expect do
          do_request
        end.to change(Figure, :count).by 1
      end

      it "queues up a download job" do
        expect(DownloadAttachmentWorker).to receive(:download_attachment) do |figure, url_, user_|
          expect(figure.paper).to eq(paper)
          expect(user_).to eq(user)
          expect(url_).to eq(url)
        end
        do_request
      end

      it { is_expected.to responds_with(201) }
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "PUT 'update_attachment'" do
    subject(:do_request) do
      put :update_attachment, format: "json", id: figure.id, url: url
    end
    let(:url) { "http://someawesomeurl.com" }
    before do
      allow(figure).to receive(:update_attribute)
      allow(DownloadAttachmentWorker).to receive(:perform_async)
      allow(Figure).to receive(:find).with(figure.to_param).and_return(figure)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
      end

      it "queues up a download job" do
        expect(DownloadAttachmentWorker).to receive(:download_attachment)
          .with(figure, url, user)
        do_request
      end

      it "calls DownloadAttachmentWorker" do
        expect(DownloadAttachmentWorker).to receive(:perform_async).with(figure.id, url, user.id)
        do_request
        expect(response).to be_success
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "PUT 'cancel'" do
    subject(:do_request) do
      put :cancel, format: "json", id: figure.id
    end
    before do
      allow(Figure).to receive(:find).with(figure.to_param).and_return(figure)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
      end

      it "calls cancel_download" do
        allow(Figure).to receive(:find).and_return(figure)
        expect(figure).to receive(:cancel_download)
        do_request
        expect(response).to be_success
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "PUT 'update'" do
    subject(:do_request) do
      put(
        :update,
        id: figure.to_param,
        figure: { title: "new title", caption: 'new caption' },
        format: :json
      )
    end
    before do
      allow(Figure).to receive(:find).with(figure.to_param).and_return(figure)
      allow(figure).to receive(:update_attributes)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
      end

      it "allows updates for title and caption" do
        expect(figure).to receive(:update_attributes)
          .with("title" => "new title", "caption" => "new caption")

        do_request
      end

      it { is_expected.to responds_with(200) }
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
