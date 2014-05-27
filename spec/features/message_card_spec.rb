require 'spec_helper'

feature 'Message Cards', js: true do
  let(:admin) { create :user, admin: true }
  let(:journal) { create(:journal, :with_default_template) }
  let(:albert) { create :user }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
    assign_journal_role(journal, albert, :admin)
  end


  let(:paper) do
    FactoryGirl.create(:paper, :with_tasks, user: admin, submitted: true, journal: journal)
  end

  describe "creating a new message" do
    let(:subject_text) { 'A sample message' }
    let(:body_text) { 'Everyone add some comments to this test post.' }
    let(:participants) { [albert] }
    scenario "Admin can add a new message" do
      task_manager_page = TaskManagerPage.visit paper

      needs_editor_phase = task_manager_page.phase 'Assign Editor'
      needs_editor_phase.new_card overlay: NewMessageCardOverlay,
        subject: subject_text,
        body: body_text,
        participants: participants,
        creator: admin

      needs_editor_phase = task_manager_page.phase 'Assign Editor'
      needs_editor_phase.view_card subject_text, MessageCardOverlay do |card|
        expect(card.subject).to eq subject_text
        expect(card.comments.first).to have_text body_text
        expect(card.participants).to match_array [albert.full_name, admin.full_name]
      end
    end
  end

  describe "commenting on an existing message" do
    let(:phase) { paper.phases.first }
    let!(:initial_comment) { create :comment, commenter: commenter, task: message }
    let(:message) do
      create :message_task, phase: phase, participants: participants
    end

    context "blank comments" do
      let(:commenter) { admin }
      let(:participants) { [admin] }
      scenario "user can't add any" do
        task_manager_page = TaskManagerPage.visit paper
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          card.post_message 'Hello'
          card.post_message ''
          expect(card.comments.length).to eq 2
        end
      end
    end

    context "the user is already a participant" do
      let(:commenter) { admin }
      let(:participants) { [admin] }

      scenario "the user can add a commment" do
        task_manager_page = TaskManagerPage.visit paper
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          expect(card).to have_css('.message-overlay')
          card.post_message 'Hello'
          expect(card.participants).to match_array(participants.map(&:full_name))
          expect(card.comments.last.find('.comment-name')).to have_text(admin.full_name)
        end
      end

      scenario "the user can add any other user as a participant" do
        task_manager_page = TaskManagerPage.visit paper
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          expect(card).to have_css('.message-overlay')
          card.add_participants [albert]
          expect(card.participants).to include(albert.full_name)
        end
        task_manager_page = TaskManagerPage.visit paper
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          expect(card.participants).to include(albert.full_name)
        end
      end
    end

    context "the user isn't a participant" do
      let(:commenter) { albert }
      let(:participants) { [albert] }
      scenario "the user becomes a participant after commenting" do
        task_manager_page = TaskManagerPage.visit paper
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          expect(card).to have_css('.message-overlay')
          card.post_message 'Hello'
          expect(card.participants).to include(admin.full_name, albert.full_name)
          expect(card.comments.last.find('.comment-name')).to have_text(admin.full_name)
        end
      end
    end
  end

  describe "user can see number of unread comments as a badge on the card" do
    let(:commenter) { albert }
    let(:participants) { [admin, albert] }
    let(:phase) { paper.phases.first }
    let!(:initial_comments) do
      comment_count.times.map { create :comment, commenter: commenter, task: message }
    end
    let(:message) do
      create :message_task, phase: phase, participants: participants
    end
    let(:comment_count) { 4 }
    let(:task_manager_page) { TaskManagerPage.visit paper }

    scenario "displays the number of unread comments as badge on message card" do
      expect(task_manager_page.message_tasks.first.unread_comments_badge).to eq comment_count
    end
  end

  describe "viewing a message's comments" do
    let(:commenter) { admin }
    let(:participants) { [admin, albert] }
    let(:phase) { paper.phases.first }
    let!(:initial_comments) do
      comment_count.times.map { create :comment, commenter: commenter, task: message }
    end
    let(:message) do
      create :message_task, phase: phase, participants: participants
    end
    let(:task_manager_page) { TaskManagerPage.visit paper }

    context "the message has less than or equal to 5 comments" do
      let(:comment_count) { 4 }
      scenario "'show all comments button' is not visible. All comments are visible." do
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          expect(card).to have_css('.message-overlay')
          expect(card).to have_no_css('.comment-actions.active')
          expect(card.comments.count).to eq(initial_comments.count)
        end
      end

      describe "unread comments are highlighted" do
        let!(:initial_comments) do
          comment_count.times.map { create :comment, commenter: albert, task: message }
        end

        scenario "seen comments are marked as read" do
          task_manager_page.view_card message.title, MessageCardOverlay do |card|
            expect(card.unread_comments.length).to eq(comment_count)
          end

          task_manager_page.reload

          task_manager_page.view_card message.title, MessageCardOverlay do |card|
            expect(card.unread_comments.length).to eq(0)
          end
        end
      end
    end

    context "the message has more than 5 comments" do
      let(:comment_count) { 10 }
      scenario "'show all comments button' and the most recent 5 comments are visible" do
        task_manager_page.view_card message.title, MessageCardOverlay do |card|
          expect(card).to have_css('.message-overlay')
          expect(card).to have_css('.comment-actions')
          card.verify_comment_count 5
          expect(card.omitted_comment_count).to eq(comment_count - 5)
          card.load_comments
          card.verify_comment_count comment_count
        end
      end

      describe "unread comments are highlighted" do
        let!(:initial_comments) do
          comment_count.times.map { create :comment, commenter: albert, task: message }
        end

        scenario "seen comments are marked as read" do
          task_manager_page.view_card message.title, MessageCardOverlay do |card|
            expect(card.unread_comments.length).to eq(5)
            card.load_comments
            expect(card.unread_comments.length).to eq(comment_count)
          end
        end
      end
    end
  end
end
