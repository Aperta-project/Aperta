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

  it "doesn't send emails to @mentioned participators when a new participator is added" do
    at_mentioned_user = FactoryGirl.create(:user)
    commenter = FactoryGirl.create(:user)

    task = FactoryGirl.create(:ad_hoc_task, paper: paper)
    comment = FactoryGirl.create(:comment, commenter: commenter, task: task, body: "@#{at_mentioned_user.username} Hello!")

    expect { CommentLookManager.sync_comment(comment) }.not_to change(ActionMailer::Base.deliveries, :count)
  end
end
