require 'rails_helper'

describe Admin::LetterTemplatesController, redis: true do
  let(:journal) { create(:journal, :with_staff_admin_role) }
  let(:user) do
    ja = create(:user, first_name: 'Steve')
    assign_journal_role(journal, ja, :admin)
    ja
  end
  let(:letter_template) { create(:letter_template) }

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
          it "finds letter templates for that journal" do
            expect(LetterTemplate).to receive(:where).with(journal_id: journal.id)
            get :index, params: { format: 'json', journal_id: journal.id }
          end
        end

        it { is_expected.to responds_with(200) }
      end
    end
  end

  describe '#show' do
    subject :do_request do
      get :show, params: { format: 'json', id: letter_template.id }
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

        context 'finds the specified template' do
          it 'does things' do
            expect(LetterTemplate).to receive(:find).with(letter_template.id.to_s)
            get :show, params: { format: 'json', id: letter_template.id }
          end
        end
        it { is_expected.to responds_with(200) }
      end
    end
  end

  describe '#update' do
    subject :do_request do
      put :update, params: { format: 'json', id: letter_template.id }
    end

    it_behaves_like "an unauthenticated json request"

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context 'when the user is unauthorized' do
        it { is_expected.to responds_with(403) }
      end
      context 'the user can administer any journal' do
        before do
          allow(user).to receive(:can?)
            .with(:administer, Journal)
            .and_return true
        end

        context 'uses strong params' do
          it 'only updates with approved attributes' do
            unsanitized_params = {
              subject: 'malicious PUT',
              journal_id: 666
            }
            expect_any_instance_of(LetterTemplate).to receive(:update).with(unsanitized_params.except(:journal_id))
            put :update, params: { id: letter_template.id, letter_template: unsanitized_params, format: 'json' }
          end
        end
      end
    end
  end
end
