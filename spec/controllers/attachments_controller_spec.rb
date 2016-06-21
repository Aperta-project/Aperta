require 'rails_helper'

describe AttachmentsController do
  let(:user) { create :user }
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:paper) do
    FactoryGirl.create(:paper, journal: journal, creator: user)
  end
  let(:task) { FactoryGirl.create(:task, paper: paper) }

  describe "viewing the attachment" do
    let(:attachment) { task.attachments.create! }

    context "with permission to view the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return true
      end

      it "returns the attachment" do
        get :index, format: "json", task_id: task.to_param
        expect(response).to be_success
      end
    end

    context "without permission to view the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, task)
          .and_return false
      end

      it "returns a 403" do
        get :index, format: "json", task_id: task.to_param
        expect(response.status).to eq(403)
      end
    end
  end

  describe "destroying the attachment" do
    subject(:do_request) { delete :destroy, id: task.attachments.last.id, paper_id: paper.id }
    before(:each) do
      task.attachments.create!
    end

    context "with permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "destroys the attachment record" do
        expect { do_request }.to change { Attachment.count }.by(-1)
      end
    end

    context "without permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it "leaves the attachment alone" do
        expect { do_request }.to change { Attachment.count }.by(0)
      end

      it "returns a 403" do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "POST 'create'" do
    let(:url) { "http://someawesomeurl.com" }
    context "with permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "causes the creation of the attachment" do
        expect(DownloadAdhocTaskAttachmentWorker).to receive(:perform_async)
        post :create, format: "json", task_id: task.to_param, title: 'Cool'
        expect(response).to be_success
      end
    end

    context "without permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it "returns a 403" do
        post :create, format: "json", task_id: task.to_param, title: 'Cool'
        expect(response.status).to eq(403)
      end
    end
  end

  describe "PUT 'update_attachment'" do
    let(:url) { "http://someawesomeurl.com" }
    let(:attachment) { task.attachments.create! }

    context "with permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "calls DownloadAdhocTaskAttachmentWorker" do
        expect(DownloadAdhocTaskAttachmentWorker).to receive(:perform_async).with(attachment.id, url)
        put :update_attachment, format: "json", task_id: task.to_param, id: attachment.id, url: url
        expect(response).to be_success
      end
    end

    context "without permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it "returns a 403" do
        put :update_attachment, format: "json", task_id: task.to_param, id: attachment.id, url: url
        expect(response.status).to eq(403)
      end
    end
  end

  describe "PUT 'update'" do
    subject(:do_request) do
      patch :update,
            id: task.attachments.last.id,
            task_id: task.id,
            attachment: {
              title: "new title",
              caption: "new caption"
            },
            format: :json
    end

    before(:each) do
      task.attachments.create!
    end

    context "with permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return true
      end

      it "allows updates for title and caption" do
        do_request

        attachment = task.attachments.last
        expect(attachment.caption).to eq("new caption")
        expect(attachment.title).to eq("new title")
      end
    end

    context "without permission to edit the task" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, task)
          .and_return false
      end

      it "returns a 403" do
        do_request

        expect(response.status).to eq(403)
      end
    end
  end
end
