require 'rails_helper'

describe CommentLookManager do
  it "creates a comment look if the user was already a participant" do
    user = FactoryGirl.create(:user)
    participant = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [participant])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    look = CommentLookManager.create_comment_look(participant, comment)

    expect(look).to_not be_nil
  end

  it "doesn't create a comment look if the comment was created before the user became a participant" do
    user = FactoryGirl.create(:user)
    task = FactoryGirl.create(:task)
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    participant = FactoryGirl.create(:user)
    task.add_participant(participant)

    look = CommentLookManager.create_comment_look(participant, comment)

    expect(look).to be_nil
  end

  it "does not create a comment look for the user that created the comment" do
    user = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [user])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    look = CommentLookManager.create_comment_look(user, comment)
    expect(look).to be_nil
  end

  it "doesn't make comment look for non-participants even if they comment" do
    participant = FactoryGirl.create(:user)
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [participant])
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task)

    look = CommentLookManager.create_comment_look(commenter, comment)
    expect(look).to be_nil
  end
end
