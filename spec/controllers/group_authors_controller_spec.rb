require 'rails_helper'

describe GroupAuthorsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:authors_task, paper: paper) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:post_request) do
    post :create,
         format: :json,
         group_author: {
           name: "Freddy Group",
           contact_first_name: "enrico",
           contact_last_name: "fermi",
           paper_id: paper.id,
           task_id: task.id,
           position: 1
         }
  end
  let!(:group_author) { FactoryGirl.create(:group_author, paper: paper, task_id: task.id) }
  let(:delete_request) { delete :destroy, format: :json, id: group_author.id }
  let(:put_request) do
    put :update,
        format: :json,
        id: group_author.id,
        group_author: {
          contact_last_name: "Blabby",
          task_id: task.id }
  end

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "when the current user can edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(true)
    end

    it 'a POST request creates a new author' do
      expect { post_request }.to change { GroupAuthor.count }.by(1)
    end

    it 'a PUT request updates the author' do
      put_request
      expect(group_author.reload.contact_last_name).to eq "Blabby"
    end

    it 'a DELETE request deletes the author' do
      expect { delete_request }.to change { GroupAuthor.count }.by(-1)
    end
  end

  describe "when the current user can NOT edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(false)
    end

    it 'a POST request does not create a new author' do
      expect { post_request }.not_to change { GroupAuthor.count }
    end

    it 'a PUT request does not update an author' do
      put_request
      expect(group_author.reload.contact_last_name).not_to eq "Blabby"
    end

    it 'a DELETE request does not delete an author' do
      expect { delete_request }.not_to change { GroupAuthor.count }
    end

    it 'a POST request responds with a 403' do
      post_request
      expect(response).to have_http_status(:forbidden)
    end

    it 'a PUT request responds with a 403' do
      put_request
      expect(response).to have_http_status(:forbidden)
    end

    it 'a DELETE request responds with a 403' do
      delete_request
      expect(response).to have_http_status(:forbidden)
    end
  end
end
