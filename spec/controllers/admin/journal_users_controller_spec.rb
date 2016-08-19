require 'rails_helper'

describe Admin::JournalUsersController, redis: true do
  let(:journal) { create(:journal, :with_staff_admin_role) }
  let(:user) do
    ja = create(:user, first_name: 'Steve')
    assign_journal_role(journal, ja, :admin)
    ja
  end

  describe '#index' do
    subject :do_request do
      get :index, format: 'json'
    end

    it_behaves_like "an unauthenticated json request"

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context "when the user is unauthorized" do
        it { is_expected.to responds_with(403) }
      end

      context 'the user can administer any journal' do
        before do
          allow(user).to receive(:can?)
            .with(:administer, Journal)
            .and_return true
        end

        context "when there's a query in the params" do
          it "fuzzy searches and for users that match the query" do
            expect(User).to receive(:search_users).with('Alice')
            get :index, format: 'json', query: 'Alice'
          end
        end

        context "when there's a journal id in the params" do
          it "finds users assigned to that journal" do
            expect(User).to receive(:assigned_to_journal).with(journal.id)
            get :index, format: 'json', journal_id: journal.id
          end
        end

        context "when neither a query or a journal id are present" do
          it "returns no users" do
            expect(User).to receive(:none)
            get :index, format: 'json'
          end
        end

        it { is_expected.to responds_with(200) }
      end
    end
  end

  describe '#update' do
    let(:fake_user) do
      fake = create(:user)
      allow(User).to receive(:find).with(fake.to_param).and_return(fake)
      fake
    end

    context 'no journal_id is present in the user params' do
      subject(:do_request) do
        patch :update,
          format: 'json',
          id: fake_user.id,
          admin_journal_user: { first_name: 'Alice',
                                last_name: 'Smith',
                                username: 'asmith',
                                journal_role_name: 'Staff Admin',
                                modify_action: 'add-role' }
      end

      it_behaves_like "an unauthenticated json request"

      context 'when the user is signed in' do
        before do
          stub_sign_in user
        end

        context "when the user does not have access" do
          it { is_expected.to responds_with(403) }
        end

        context "when the user can administer any Journal" do
          before do
            allow(user).to receive(:can?)
              .with(:administer, Journal)
              .and_return true
          end

          it { is_expected.to responds_with(204) }

          it "updates the user" do
            expect(fake_user).to receive(:update)
            do_request
          end
        end
      end
    end

    describe 'adding or removing roles for a user with a journal_id' do
      let(:modify_action) { 'remove-role' }
      subject(:do_request) do
        patch :update,
          format: 'json',
          id: fake_user.id,
          admin_journal_user: { first_name: 'Alice',
                                last_name: 'Smith',
                                username: 'asmith',
                                journal_role_name: 'Staff Admin',
                                journal_id: journal.id,
                                modify_action: modify_action }
      end

      it_behaves_like "an unauthenticated json request"

      context 'the user is signed in' do
        before do
          stub_sign_in user
        end

        context "when the user does not have access" do
          it { is_expected.to responds_with(403) }
        end

        context "when the user can administer the specific journal" do
          before do
            allow(user).to receive(:can?)
              .with(:administer, journal)
              .and_return true
          end

          context "adding a role" do
            let(:modify_action) { 'add-role' }
            it 'adds the role specified' do
              expect(fake_user).to receive(:assign_to!).with(assigned_to: journal, role: 'Staff Admin')
              do_request
            end
          end

          context "removing a role" do
            it "removes the role specified" do
              expect(fake_user).to receive(:resign_from!).with(assigned_to: journal, role: 'Staff Admin')
              do_request
            end
          end
        end
      end
    end
  end
end
