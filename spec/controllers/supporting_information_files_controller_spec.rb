require 'rails_helper'

describe SupportingInformationFilesController, redis: true do
  let(:user) { create :user }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: user)
  end
  let(:task) { FactoryGirl.create(:supporting_information_task, paper: paper) }
  let(:file) { FactoryGirl.create(:supporting_information_file, paper: paper) }
  before { sign_in user }

  describe 'DELETE #destroy' do
    it 'destroys the file record' do
      file
      expect do
        delete :destroy, id: file.id
      end.to change { SupportingInformationFile.count }.by(-1)
    end
  end

  describe 'POST #create' do
    it 'creates the supporting file' do
      url = 'http://someawesomeurl.com'
      expect(DownloadSupportingInfoWorker).to receive(:perform_async)
      post :create, format: 'json', task_id: task.id, url: url
      expect(response.status).to eq(201)
    end
  end

  describe 'PUT #update' do
    it 'allows updates for title and caption' do
      with_aws_cassette 'supporting_info_files_controller' do
        put :update, id: file.id,
                     supporting_information_file: { title: 'new title',
                                                    caption: 'new caption' },
                     format: :json
        expect(file.reload.caption).to eq('new caption')
        expect(file.title).to eq('new title')
      end
    end
  end
end
