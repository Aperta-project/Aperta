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

describe Admin::LetterTemplatesController, redis: true do
  let!(:journal) { create(:journal, :with_admin_roles) }
  let(:user) do
    ja = create(:user, first_name: 'Steve')
    assign_journal_role(journal, ja, :admin)
    ja
  end
  let!(:letter_template) { create(:letter_template, journal: journal) }

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
            .with(:manage_users, Journal)
            .and_return true
        end

        context "when there's a query in the params" do
          it "finds letter templates for that journal" do
            expect_any_instance_of(Journal).to receive(:letter_templates)
            get :index, format: 'json', journal_id: journal.id
          end
        end

        it { is_expected.to responds_with(200) }
      end
    end
  end

  describe '#show' do
    subject :do_request do
      get :show, format: 'json', id: letter_template.id
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
            .with(:manage_users, Journal)
            .and_return true
        end

        context 'finds the specified template' do
          it 'does things' do
            expect(LetterTemplate).to receive(:find).with(letter_template.id.to_s)
            get :show, format: 'json', id: letter_template.id
          end
        end
        it { is_expected.to responds_with(200) }
      end
    end
  end

  describe '#update' do
    subject :do_request do
      put :update, format: 'json', id: letter_template.id
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
            .with(:manage_users, Journal)
            .and_return true
        end

        context 'uses strong params' do
          it 'only updates with approved attributes' do
            unsanitized_params = {
              subject: 'malicious PUT',
              journal_id: 666
            }
            expect_any_instance_of(LetterTemplate).to receive(:update).with(unsanitized_params.except(:journal_id))
            put :update, id: letter_template.id, letter_template: unsanitized_params, format: 'json'
          end
        end
      end
    end
  end

  describe '#preview' do
    subject :do_request do
      post :preview, format: 'json', id: letter_template.id, letter_template: { subject: "{{journal.name}}" }
    end

    it_behaves_like "an unauthenticated json request"

    context 'when the user is signed in' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_users, Journal)
          .and_return true
        allow(LetterTemplate).to receive(:find).with(letter_template.id.to_s) { letter_template }
      end

      it 'responds with 201' do
        allow(letter_template).to receive(:render_dummy_data)
        do_request
        is_expected.to responds_with(201)
      end

      it 'returns dummy data rendered into the template' do
        expect(letter_template).to receive(:render_dummy_data)
        do_request
        expect(res_body['letter_template']['subject']).to be_present
        expect(res_body['letter_template']['body']).to be_present
      end

      it 'sends error messages if template validations fail' do
        post :preview, format: 'json', id: letter_template.id, letter_template: { subject: "{{journal.name}" }
        expect(res_body['errors']['subject']).to be_present
      end
    end
  end
end
