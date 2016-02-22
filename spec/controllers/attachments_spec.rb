require 'rails_helper'

describe AttachmentsController do
  let(:user) { create :user }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, creator: user)
  end
  let(:task) { FactoryGirl.create(:task, paper: paper) }

  before { sign_in user }

  describe "destroying the attachment" do
    subject(:do_request) { delete :destroy, id: task.attachments.last.id, paper_id: paper.id }
    before(:each) do
      task.attachments.create!
    end

    it "destroys the attachment record" do
      expect {
        do_request
      }.to change{Attachment.count}.by -1
    end
  end

  describe "POST 'create'" do
    let(:url) { "http://someawesomeurl.com" }
    it "causes the creation of the attachment" do
      expect(DownloadAdhocTaskAttachmentWorker).to receive(:perform_async)
      post :create, format: "json", task_id: task.to_param, title: 'Cool'
      expect(response).to be_success
    end
  end

  describe "PUT 'update_attachment'" do
    let(:url) { "http://someawesomeurl.com" }
    let(:attachment) { task.attachments.create! }
    it "calls DownloadAdhocTaskAttachmentWorker" do
      expect(DownloadAdhocTaskAttachmentWorker).to receive(:perform_async).with(attachment.id, url)
      put :update_attachment, format: "json", task_id: task.to_param, id: attachment.id, url: url
      expect(response).to be_success
    end
  end

  describe "PUT 'update'" do
    subject(:do_request) { patch :update, id: task.attachments.last.id, task_id: task.id, attachment: {title: "new title", caption: "new caption"}, format: :json }
    before(:each) do
      task.attachments.create!
    end

    it "allows updates for title and caption" do
      do_request

      attachment = task.attachments.last
      expect(attachment.caption).to eq("new caption")
      expect(attachment.title).to eq("new title")
    end
  end
end
