require 'rails_helper'

describe Admin::JournalUsersController, redis: true do
  let(:journal) { create(:journal_with_roles_and_permissions) }
  let(:journal_admin) do
    ja = create(:user)
    assign_journal_role(journal, ja, :admin)
    ja
  end
  let(:journal_admin2) do
    ja = create :user
    assign_journal_role(journal, ja, :admin)
    ja
  end
  let(:user) { create(:user) }

  describe '#index' do
    subject :do_request do
      get  :index,
           format: 'json',
           admin_journal: { query: 'Alice', journal_id: journal.id }
    end


    it_behaves_like "an unauthenticated json request"

    context 'when the user has access' do
      before do
        stub_sign_in journal_admin
      end

      it "renders status 2xx and the user is a journal admin" do
        do_request
        expect(response.status).to eq 200
      end
    end

    context "when the user is unauthorized" do
      before do
        stub_sign_in user
      end

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end
    end
  end

  describe '#update' do
    describe 'add-role' do
      subject(:do_request) do
        patch :update,
              format: 'json',
              id: user.id,
              admin_journal_user: { first_name: 'Alice',
                                    last_name: 'Smith',
                                    username: 'asmith',
                                    journal_role_name: 'Staff Admin',
                                    journal_id: journal.id,
                                    modify_action: 'add-role' }
      end

      it_behaves_like "an unauthenticated json request"

      context "when the user has access" do
        before do
          stub_sign_in journal_admin
        end

        it "renders status 2xx and the user is a journal admin" do
          do_request
          expect(response.status).to eq 204
        end
      end

      context "when the user does not have access" do
        before do
          stub_sign_in user
        end

        it "renders status 403" do
          do_request
          expect(response.status).to eq 403
        end
      end
    end

    describe 'remove-role' do
      subject(:do_request) do
        patch :update,
              format: 'json',
              id: journal_admin2.id,
              admin_journal_user: { first_name: 'Alice',
                                    last_name: 'Smith',
                                    username: 'asmith',
                                    journal_role_name: 'Staff Admin',
                                    journal_id: journal.id,
                                    modify_action: 'remove-role' }
      end

      context "when the user has access" do
        before do
          stub_sign_in journal_admin
        end

        it "removes the role specified" do
          expect(journal_admin2.can?(:administer, journal)).to be_truthy
          do_request
          expect(journal_admin2.can?(:administer, journal)).to be_falsy
          expect(response.status).to eq 204
        end
      end

      context "when the user does not have access" do
        before do
          stub_sign_in user
        end

        it "renders status 403" do
          do_request
          expect(response.status).to eq 403
        end
      end
    end
  end
end
