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

require "rails_helper"

describe TokenCoauthorsController do
  let(:author) { FactoryGirl.create(:author) }
  before do
    FactoryGirl.create(:setting_template,
     key: "Journal",
     setting_name: "coauthor_confirmation_enabled",
     value_type: 'boolean',
     boolean_value: true)

    author.paper.journal.setting("coauthor_confirmation_enabled").update!(value: true)
  end

  describe 'GET api/token_coauthors/:token' do
    it 'finds the author for the token' do
      get :show, token: author.token
      expect(res_body[:token_coauthor][:id]).to eq(author.token)
    end

    it 'finds the group author for the token' do
      group_author = FactoryGirl.create(:group_author)
      group_author.paper.journal.setting("coauthor_confirmation_enabled").update!(value: true)

      get :show, token: group_author.token
      expect(res_body[:token_coauthor][:id]).to eq(group_author.token)
    end

    context 'the token does not match any author' do
      it 'renders a 404' do
        get :show, token: 'foobarbazbarfoo'
        expect(response.status).to eq(404)
      end
    end

    context "coauthor confirmation is disabled" do
      before do
        author.paper.journal.setting("coauthor_confirmation_enabled").update(value: false)
      end

      it "renders a 404" do
        get :show, token: author.token
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'PUT /token_coauthors/:token' do
    it 'confirms the author' do
      expect(author.co_author_state).to eq('unconfirmed')
      put :update, token: author.token

      expect(author.reload.co_author_state).to eq('confirmed')
    end

    it 'confirms the group author' do
      group_author = FactoryGirl.create(:group_author)
      group_author.paper.journal.setting("coauthor_confirmation_enabled").update!(value: true)
      expect(group_author.co_author_state).to eq('unconfirmed')
      put :update, token: group_author.token

      expect(group_author.reload.co_author_state).to eq('confirmed')
    end

    context 'the authorship is refuted' do
      it 'confirms the author' do
        author.update_attributes!(co_author_state: 'refuted')
        put :update, token: author.token

        expect(author.reload.co_author_state).to eq('confirmed')
      end
    end

    context 'the author is already confirmed' do
      it 'does not add an event to the activity feed' do
        author.update_attributes!(co_author_state: 'confirmed')
        expect { put :update, token: author.token }.to_not change(Activity, :count)
      end
    end

    context 'the token does not match any author' do
      it 'renders a 404' do
        put :update, token: 'foobarbazbarfoo'
        expect(response.status).to eq(404)
      end
    end

    context 'coauther confirmation is disabled' do
      before do
        author.paper.journal.setting("coauthor_confirmation_enabled").update(value: false)
      end

      it "renders a 404" do
        put :update, token: author.token
        expect(author.co_author_state).to eq('unconfirmed')
      end

      it 'does not update the confirmation state' do
        put :update, token: author.token
        expect(response.status).to eq(404)
      end
    end
  end
end
