require 'rails_helper'

describe CommentLookManager do
  it "creates a comment look if the user was already a participant" do
    user = FactoryGirl.create(:user)
    participant = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [participant])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    look = CommentLookManager.create_comment_look(participant, comment)

    expect(look).to_not be_nil
    expect(look.read_at).to be_nil
  end

  it "doesn't create a comment look if the comment was created before the user became a participant" do
    user = FactoryGirl.create(:user)
    task = FactoryGirl.create(:task)
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    participant = FactoryGirl.create(:user)
    task.participants << participant

    look = CommentLookManager.create_comment_look(participant, comment)

    expect(look).to be_nil
  end

  it "does not create a new comment look records if it already exists" do
    user = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [user])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    look = CommentLookManager.create_comment_look(user, comment)
    expect(look).to_not be_nil

    another_look = CommentLookManager.create_comment_look(user, comment)
    expect(look).to eq(another_look)
  end

  it "doesn't make comment look for non-participants even if they comment" do
    participant = FactoryGirl.create(:user)
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [participant])
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task)

    look = CommentLookManager.create_comment_look(commenter, comment)
    expect(look).to be_nil
  end

  it "creates a comment_look on comment for commenter and sets the read_at to the current time" do
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [commenter])
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task)

    look = CommentLookManager.create_comment_look(commenter, comment)
    expect(look.read_at).to_not be_nil
  end
end
