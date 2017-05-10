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
  let!(:group_author) { FactoryGirl.create(:group_author, paper: paper) }
  let(:delete_request) { delete :destroy, format: :json, id: group_author.id }
  let(:put_request) do
    put :update,
        format: :json,
        id: group_author.id,
        group_author: {
          contact_last_name: "Blabby",
          task_id: task.id
        }
  end

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "when the current user can edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:administer, group_author.paper.journal).and_return(true)
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

  describe 'coauthor update' do
    let!(:time) { Time.now.utc }

    let!(:staff_admin) { FactoryGirl.create(:user, :site_admin) }

    let(:group_author) do
      Timecop.freeze(1.day.ago) do
        FactoryGirl.create(:group_author, co_author_state: "unconfirmed",
                                          co_author_state_modified_at: time,
                                          co_author_state_modified_by_id: staff_admin.id,
                                          paper: paper)
      end
    end

    let(:put_request) do
      put :update, format: :json, id: group_author.id, group_author: { contact_last_name: "Blabby",
                                                                       author_task_id: task.id,
                                                                       co_author_state: "confirmed",
                                                                       co_author_state_modified_by: staff_admin }
    end

    context 'administrator user' do
      it 'a PUT request from an administrator allows updating coauthor status' do
        allow(user).to receive(:can?).with(:edit_authors, group_author.paper).and_return(true)
        allow(user).to receive(:can?).with(:administer, group_author.paper.journal).and_return(true)

        old_time = group_author.co_author_state_modified_at

        put_request
        group_author.reload
        expect(group_author.contact_last_name).to eq "Blabby"
        expect(group_author.co_author_state).to eq "confirmed"
        expect(group_author.co_author_state_modified_at).to be > old_time
        expect(group_author.co_author_state_modified_by_id).to eq user.id
      end

      context 'non-administrator user with edit access'

      it 'a PUT request from an non-administrator skips updating coauthor status' do
        allow(user).to receive(:can?).with(:edit_authors, group_author.paper).and_return(true)
        allow(user).to receive(:can?).with(:administer, group_author.paper.journal).and_return(false)

        old_time = group_author.co_author_state_modified_at

        put_request
        group_author.reload
        expect(group_author.contact_last_name).to eq "Blabby"
        expect(group_author.co_author_state).to eq "unconfirmed"
        # TODO: Fix time issue on CI
        # expect(group_author.co_author_state_modified_at).to eq old_time
        expect(group_author.co_author_state_modified_by_id).to eq staff_admin.id
      end
    end
  end
end
