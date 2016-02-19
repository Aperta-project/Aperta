require 'rails_helper'

describe AuthorsController do
  let(:task) { FactoryGirl.create(:authors_task, paper: paper) }
  let(:journal) do
    FactoryGirl.create(:journal,
                       :with_publishing_services_user,
                       :with_staff_admin_user)
  end
  let(:paper) do
    FactoryGirl.create(:paper,
                       :with_handling_editor_user,
                       :with_internal_editor_user,
                       journal: journal)
  end
  let(:post_request) do
    post :create,
         format: :json,
         author: {
           first_name: "enrico",
           last_name: "fermi",
           paper_id: paper.id,
           authors_task_id: task.id,
           position: 1
         }
  end
  let!(:author) { FactoryGirl.create(:author, paper: paper, authors_task_id: task.id) }
  let(:delete_request) { delete :destroy, format: :json, id: author.id }
  let(:put_request) do
    put :update, format: :json, id: author.id, author: { last_name: "Blabby", author_task_id: task.id }
  end

  before do
    sign_in user
  end

  shared_examples_for 'user who can edit authors' do
    it 'a POST request creates a new author' do
      expect { post_request }.to change { Author.count }.by(1)
    end

    it 'a PUT request updates the author' do
      put_request
      expect(author.reload.last_name).to eq "Blabby"
    end

    it 'a DELETE request deletes the author' do
      expect { delete_request }.to change { Author.count }.by(-1)
    end
  end

  shared_examples_for 'user who cannot edit authors' do
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

  context "when the current user is assigned the creator role on the paper" do
    let(:user) { paper.creator }

    # These tests are possibly too much
    context 'and the paper is in a user-editable state' do
      Paper::EDITABLE_STATES.each do |state|
        describe "and the state is #{state}" do
          let(:paper) { FactoryGirl.create(:paper, publishing_state: state) }

          include_examples 'user who can edit authors'
        end
      end

      context 'and the paper is NOT in a user-editable state' do
        Paper::UNEDITABLE_STATES.each do |state|
          describe "and the state is #{state}" do
            let(:paper) { FactoryGirl.create(:paper, publishing_state: state) }

            include_examples 'user who cannot edit authors'
          end
        end
      end
    end
  end

  [:publishing_services_role, :staff_admin_role].each do |role|
    context "when the current user is assigned the #{role} on the journal" do
      let(:user) { journal.assignments.where(role: journal.send(role)).first.user }

      include_examples 'user who can edit authors'
    end
  end

  [:handling_editor_role, :internal_editor_role].each do |role|
    context "when the current user is assigned the #{role} on the paper" do
      let(:user) { paper.assignments.where(role: journal.send(role)).first.user }

      include_examples 'user who can edit authors'
    end
  end

  context 'when the current user has no relevant role' do
    let(:user) { FactoryGirl.create(:user) }

    include_examples 'user who cannot edit authors'
  end
end
