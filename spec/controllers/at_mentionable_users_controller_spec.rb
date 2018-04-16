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

describe AtMentionableUsersController do
  let(:user) { create(:user) }
  let(:mentionable_user) { create(:user) }
  let!(:discussion_topic) { create(:discussion_topic) }
  let(:paper) { create(:paper) }

  before { sign_in user }

  describe '#index' do
    subject(:do_request) do
      get :index,
          format: :json,
          on_paper_id: paper.id
    end

    before do
      allow(User).to receive(:who_can).and_return [mentionable_user]
    end

    context 'the user is authorized' do
      it 'returns users who can be at-mentioned' do
        do_request
        expect(response.status).to eq 200
        data = JSON.parse(response.body)
        expect(data['users'].count).to eq 1
        user_data = data['users'].first
        expect(user_data['id']).to eq mentionable_user.id
      end
    end
  end
end
