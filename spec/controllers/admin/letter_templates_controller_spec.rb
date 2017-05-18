require 'rails_helper'

describe Admin::LetterTemplatesController, redis: true do
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
          it "finds letter templats for that journal" do
            expect(LetterTemplate).to receive(:where).with(journal_id: journal.id)
            get :index, format: 'json', journal_id: journal.id
          end
        end

        it { is_expected.to responds_with(200) }
      end
    end
  end
end
