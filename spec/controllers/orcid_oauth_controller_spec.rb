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

describe OrcidOauthController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }
  let(:code) { '123456' }
  let(:error) { 'some_error' }

  describe '#callback:' do
    subject(:do_request) do
      get :callback, code: code, format: :html
    end

    it_behaves_like "when the user is not signed in"

    context 'when the user is signed in,' do
      before do
        stub_sign_in(user)
      end

      context 'and there is an error passed in,' do
        subject(:do_request) do
          get :callback, error: error, format: :html
        end

        it "does not call the OrcidWorker" do
          expect(OrcidWorker).not_to receive(:perform_async)
          do_request
        end
      end

      context 'and there is no error passed in,' do
        it "calls the OrcidWorker" do
          allow(controller).to receive(:current_user).and_return(user)
          allow(OrcidWorker).to receive(:perform_async)
          expect(OrcidWorker).to receive(:perform_async).with(user.id, code)
          do_request
        end
      end
    end
  end
end
