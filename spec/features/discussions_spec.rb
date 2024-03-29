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
require 'support/pages/discussions_page'

feature "Discussions", js: true, selenium: true do
  let(:admin) { FactoryGirl.create :user }
  let(:creator) { FactoryGirl.create :user }
  let(:mentioned_username) { 'charmander' }
  let!(:mentioned_user) do
    FactoryGirl.create(:user, username: mentioned_username).tap do |u|
      assign_journal_role(journal, u, :editor)
    end
  end
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
  let!(:paper) { FactoryGirl.create :paper, :submitted, :with_tasks, creator: creator, journal: journal }
  let(:discussion_page) { DiscussionsPage.new }
  let!(:other_person) { create :user, username: 'pickachu' }

  context 'access paper and manage discussions' do
    scenario 'can add topics, participants, and replies' do
      assign_journal_role journal, admin, :admin

      login_as(admin, scope: :user)
      visit "/papers/#{paper.id}"

      find('#nav-discussions').click

      # create new topic
      discussion_page.new_topic
      discussion_page.expect_participant(admin)
      discussion_page.add_a_participant(user: other_person, fragment: 'picka')
      discussion_page.fill_in_topic(title: 'Great', comment: 'Awesome')
      discussion_page.expect_participant(other_person)
      discussion_page.confirm_create_topic
      # ensure topic created
      discussion_page.expect_topic_created_succesfully(admin)
      discussion_page.expect_participant(admin)
      discussion_page.expect_participant(other_person)
      discussion_page.expect_can_add_participant
      # add discussion reply
      discussion_page.add_reply_mentioning_user(mentioned_user, fragment: 'char')
      discussion_page.expect_reply_count(2)
      discussion_page.expect_reply_mentioning_user(by: admin, mentioned: mentioned_user)
    end
  end

  context 'access to paper no access to discussions' do
    let(:user) { create :user }
    let!(:discussion_topic) { FactoryGirl.create :discussion_topic, paper: paper }

    before { paper.add_collaboration(user) }

    scenario 'can view paper, no discussions load' do
      login_as(user, scope: :user)
      visit "/papers/#{paper.id}"
      find('#nav-discussions').click
      discussion_page.expect_no_create_button
      discussion_page.expect_view_no_discussions
    end
  end

  context 'access to paper, participant only on a discussion' do
    let(:user) { create :user }
    let!(:discussion_topic) { FactoryGirl.create :discussion_topic, paper: paper }
    let!(:discussion_participant) { FactoryGirl.create :discussion_participant, user: user, discussion_topic: discussion_topic }

    before do
      paper.add_collaboration(user)
      discussion_topic.add_discussion_participant(discussion_participant)
    end

    scenario 'can see discussion and add reply' do
      login_as(user, scope: :user)
      visit "/papers/#{paper.id}/discussions"

      discussion_page.expect_no_create_button
      discussion_page.click_topic

      discussion_page.expect_view_topic
      discussion_page.expect_view_only_participants
      discussion_page.add_reply
      discussion_page.expect_reply_created(user, 1)
    end
  end

  context 'can see user replies on discussion in popout window' do
    let(:user) { create :user }
    let!(:discussion_topic) { FactoryGirl.create :discussion_topic, paper: paper }
    let!(:discussion_participant) { FactoryGirl.create :discussion_participant, user: user, discussion_topic: discussion_topic }

    before do
      paper.add_collaboration(user)
      discussion_topic.add_discussion_participant(discussion_participant)
    end

    scenario 'can see discussion and add reply' do
      login_as(user, scope: :user)
      # the discussion url in popout window
      visit "/discussions/#{paper.id}/#{discussion_topic.id}"

      discussion_page.expect_view_topic
      discussion_page.expect_view_only_participants
      discussion_page.add_reply
      discussion_page.expect_reply_created(user, 1)
    end
  end
end
