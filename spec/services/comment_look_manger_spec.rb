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

describe CommentLookManager do
  let!(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
  let!(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

  it "creates a comment look if the user was already a participant" do
    user = FactoryGirl.create(:user)
    participant = FactoryGirl.create(:user)

    task = FactoryGirl.create(:ad_hoc_task, paper: paper)
    task.add_participant(participant)

    comment = FactoryGirl.create(:comment, commenter: user, task: task)
    look = CommentLookManager.create_comment_look(participant, comment)

    expect(look).to_not be_nil
  end

  it "doesn't create a comment look if the comment was created before the user became a participant" do
    user = FactoryGirl.create(:user)
    task = FactoryGirl.create(:ad_hoc_task, paper: paper)
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    participant = FactoryGirl.create(:user)
    task.add_participant(participant)

    look = CommentLookManager.create_comment_look(participant, comment)

    expect(look).to be_nil
  end

  it "does not create a comment look for the user that created the comment" do
    user = FactoryGirl.create(:user)

    task = FactoryGirl.create(:ad_hoc_task, paper: paper, participants: [user])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    look = CommentLookManager.create_comment_look(user, comment)
    expect(look).to be_nil
  end

  it "doesn't make comment look for non-participants even if they comment" do
    participant = FactoryGirl.create(:user)
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:ad_hoc_task, paper: paper, participants: [participant])
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task)

    look = CommentLookManager.create_comment_look(commenter, comment)
    expect(look).to be_nil
  end
end
