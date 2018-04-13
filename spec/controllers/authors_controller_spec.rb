# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe AuthorsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:authors_task, :with_loaded_card, paper: paper) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:enrico) do
    {
      first_name: "enrico",
      last_name: "fermi",
      email: "enrico@fermilabs.org",
      paper_id: paper.id,
      task_id: task.id
    }
  end

  let(:post_request) do
    post :create,
         format: :json,
         author: enrico
  end

  let(:post_request2) do
    post :create,
         format: :json,
         author: enrico
  end

  let!(:author) { FactoryGirl.create(:author, paper: paper) }
  let(:delete_request) { delete :destroy, format: :json, id: author.id }
  let(:put_request) do
    put :update, format: :json, id: author.id, author: { last_name: "Blabby", author_task_id: task.id }
  end

  before do
    CardLoader.load("Author")
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "when the current user can edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:view, paper).and_return(true)
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(true)
      allow(user).to receive(:can?).with(:manage_paper_authors, paper).and_return(false)
    end

    it 'a POST request creates a new author' do
      expect { post_request }.to change { Author.count }.by(1)
    end

    it 'a POST request associates a new author to an existing card version' do
      post_request
      default_card = Card.find_by_class_name!(Author)
      expect(Author.last.card_version).to eq(default_card.latest_published_card_version)
    end

    it 'a PUT request updates the author' do
      put_request
      expect(author.reload.last_name).to eq "Blabby"
    end

    context 'the author belongs to a user with an orcid account and orcid connect is enabled' do
      before do
        allow_any_instance_of(TahiEnv).to receive(:orcid_connect_enabled?).and_return(true)
        user = FactoryGirl.create(:user)
        author.update!(user: user)
        FactoryGirl.create(:orcid_account, user: user)
      end
      it 'serializes the orcid account for the author' do
        put_request
        expect(res_body).to have_key('orcid_accounts')
      end
    end

    it 'a DELETE request deletes the author' do
      expect { delete_request }.to change { Author.count }.by(-1)
    end
  end

  describe "duplicate emails per paper are not allowed" do
    before do
      allow(user).to receive(:can?).with(:view, paper).and_return(true)
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(true)
      allow(user).to receive(:can?).with(:manage_paper_authors, paper).and_return(false)
    end

    it 'duplicate author emails on a paper are not allowed' do
      expect { post_request }.to change { Author.count }.by(1)
      expect(response.status).to eq 200

      response = post_request2
      expect { response }.to change { Author.count }.by(0)
      expect(response.status).to eq 422
    end
  end

  describe "when the current user can NOT edit_authors on the paper" do
    before do
      allow(user).to receive(:can?).with(:edit_authors, paper).and_return(false)
      allow(user).to receive(:can?).with(:manage_paper_authors, paper).and_return(false)
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

    context 'paper-manager user' do
      it 'a PUT request from an paper-manager allows updating coauthor status' do
        allow(user).to receive(:can?).with(:view, paper).and_return(true)
        allow(user).to receive(:can?).with(:edit_authors, paper).and_return(true)
        allow(user).to receive(:can?).with(:manage_paper_authors, paper).and_return(true)

        old_time = author.co_author_state_modified_at

        put_request
        author.reload
        expect(author.last_name).to eq "Blabby"
        expect(author.co_author_state).to eq "confirmed"
        expect(author.co_author_state_modified_at).to be > old_time
        expect(author.co_author_state_modified_by_id).to eq user.id
      end

      context 'non-paper-manager user with edit access'

      it 'a PUT request from an non-paper-managerskips updating coauthor status' do
        allow(user).to receive(:can?).with(:view, paper).and_return(true)
        allow(user).to receive(:can?).with(:edit_authors, author.paper).and_return(true)
        allow(user).to receive(:can?).with(:manage_paper_authors, paper).and_return(false)

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
