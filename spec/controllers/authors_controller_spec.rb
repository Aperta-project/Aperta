require 'rails_helper'

describe AuthorsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:authors_task, paper: paper) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:card) { FactoryGirl.create(:card) }
  let(:post_request) do
    post :create,
         format: :json,
         author: {
           first_name: "enrico",
           last_name: "fermi",
           paper_id: paper.id,
           task_id: task.id,
           position: 1,
           card_id: card.id
         }
  end
  let!(:author) { FactoryGirl.create(:author, paper: paper) }
  let(:delete_request) { delete :destroy, format: :json, id: author.id }
  let(:put_request) do
    put :update, format: :json, id: author.id, author: { last_name: "Blabby", author_task_id: task.id }
  end

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "when the current user can edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(true)
      allow(user).to receive(:can?).with(:administer, paper.journal).and_return(false)
    end

    it 'a POST request creates a new author' do
      expect { post_request }.to change { Author.count }.by(1)
    end

    it 'a POST request associates a new author to an existing card' do
      post_request
      expect(Author.last.card).to eq(card)
    end

    it 'a PUT request updates the author' do
      put_request
      expect(author.reload.last_name).to eq "Blabby"
    end

    it 'a DELETE request deletes the author' do
      expect { delete_request }.to change { Author.count }.by(-1)
    end
  end

  describe "when the current user can NOT edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(false)
      allow(user).to receive(:can?).with(:administer, paper.journal).and_return(false)
    end

    it 'a POST request does not create a new author' do
      expect { post_request }.not_to change { Author.count }
    end

    it 'a PUT request does not update an author' do
      put_request
      expect(author.reload.last_name).not_to eq "Blabby"
    end

    it 'a DELETE request does not delete an author' do
      expect { delete_request }.not_to change { Author.count }
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
    let(:put_request) do
      put :update, format: :json, id: author.id, author: { last_name: "Blabby",
                                                           author_task_id: task.id,
                                                           co_author_state: "confirmed" }
    end
    let!(:staff_admin) { FactoryGirl.create(:user, :site_admin) }
    let(:author) do
      Timecop.freeze(1.day.ago) do
        FactoryGirl.create(:author, co_author_state: "unconfirmed",
                                    co_author_state_modified_by: staff_admin,
                                    paper: paper)
      end
    end

    context 'administrator user' do
      it 'a PUT request from an administrator allows updating coauthor status' do
        allow(user).to receive(:can?).with(:edit_authors, paper).and_return(true)
        allow(user).to receive(:can?).with(:administer, paper.journal).and_return(true)

        old_time = author.co_author_state_modified_at

        put_request
        author.reload
        expect(author.last_name).to eq "Blabby"
        expect(author.co_author_state).to eq "confirmed"
        expect(author.co_author_state_modified_at).to be > old_time
        expect(author.co_author_state_modified_by_id).to eq user.id
      end

      context 'non-administrator user with edit access'

      it 'a PUT request from an non-administrator skips updating coauthor status' do
        allow(user).to receive(:can?).with(:edit_authors, author.paper).and_return(true)
        allow(user).to receive(:can?).with(:administer, author.paper.journal).and_return(false)

        old_time = author.co_author_state_modified_at

        put_request
        author.reload
        expect(author.last_name).to eq "Blabby"
        expect(author.co_author_state).to eq "unconfirmed"
        # TODO: Fix time issue on CI
        # expect(author.co_author_state_modified_at).to be_within(0.1).of(old_time)
        expect(author.co_author_state_modified_by_id).to eq staff_admin.id
      end
    end
  end
end
