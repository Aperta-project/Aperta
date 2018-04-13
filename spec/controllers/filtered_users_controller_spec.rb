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

describe FilteredUsersController do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :ad_hoc_task, paper: paper }

  describe "#users" do
    subject(:do_request) do
      get(
        :users,
        format: 'json',
        paper_id: paper.to_param,
        query: 'Kangaroo'
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      let(:eligible_users) do
        [FactoryGirl.build_stubbed(:user, username: 'UserName')]
      end
      before do
        stub_sign_in(user)
        allow(User).to receive(:fuzzy_search)
          .with('Kangaroo')
          .and_return eligible_users

        do_request
      end

      it { is_expected.to responds_with(200) }

      it 'returns any user who matches the query' do
        expect(res_body['users'].count).to eq(1)
        expect(res_body['users'][0]['username']).to eq('UserName')
      end
    end
  end

  describe '#assignable_users' do
    let(:assignable_user) do
      FactoryGirl.build_stubbed(:user, username: 'FooBar')
    end
    let(:eligible_users) do
      [FactoryGirl.build_stubbed(:user, username: 'Foo'), assignable_user]
    end

    subject(:do_request) do
      get(:assignable_users, format: 'json', task_id: task.to_param, query: 'Foo')
    end
    before do
      stub_sign_in(user)
      allow(User).to receive(:fuzzy_search)
                      .with('Foo')
                      .and_return eligible_users
      allow(User).to receive(:who_can)
                      .with('be_assigned', task)
                      .and_return [assignable_user]
      do_request
    end

    it 'returns a list of users who can be assigned to a task' do
      expect(res_body['users'].count).to eq(1)
      expect(res_body['users'][0]['username']).to eq('FooBar')
    end
  end
end
