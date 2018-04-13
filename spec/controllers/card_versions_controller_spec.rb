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

describe CardVersionsController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#show' do
    subject(:do_request) do
      get :show, format: 'json', id: card_version.id
    end
    let(:card_version) { FactoryGirl.create(:card_version) }
    let(:card) { card_version.card }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context 'when the user does not have access' do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:view, card_version)
            .and_return(false)
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?).with(:view, card_version).and_return(true)
        end

        it { is_expected.to responds_with 200 }

        it 'returns the card version' do
          do_request
          expect(res_body['card_version']['id']).to be card_version.id
        end
      end
    end
  end
end
