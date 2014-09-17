require 'spec_helper'

describe CommentLookManager do
  it "creates a comment look for any participant" do
    user = FactoryGirl.create(:user)
    participant = FactoryGirl.create(:user)
    other_participant = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [participant, other_participant])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    looks = CommentLookManager.comment_looks(comment)

    expect(looks.count).to eq(2)
    expect(looks.first.read_at).to be_nil
  end

  it "does not create new comment look records if they already exist" do
    user = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [user])
    comment = FactoryGirl.create(:comment, commenter: user, task: task)

    looks = CommentLookManager.comment_looks(comment)
    expect(looks.count).to eq(1)

    more_looks = CommentLookManager.comment_looks(comment)
    expect(looks.count).to eq(1)
  end

  it "doesn't make comment looks for non-participants even if they comment" do
    participant = FactoryGirl.create(:user)
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [participant])
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task)

    looks = CommentLookManager.comment_looks(comment)
    expect(looks.count).to eq(1)
    expect(looks.first.user_id).to eq(participant.id)
  end

  it "creates a comment_look on comment for commenter and sets the read_at to the current time" do
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:task, participants: [commenter])
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task)

    looks = CommentLookManager.comment_looks(comment)
    expect(looks.first.read_at).to_not be_nil
  end
end
