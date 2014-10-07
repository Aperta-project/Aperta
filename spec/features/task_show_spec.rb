require 'spec_helper'

feature "Displaying task", js: true do
  let(:admin) { create :user, admin: true }
  let(:author) { create :user }
  let!(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, user: author }
  let(:task) { Task.where(title: "Assign Admin").first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "User visits task's show page" do
    assign_admin_overlay = CardOverlay.visit [task.paper, task]
    expect(assign_admin_overlay).to_not be_completed

    assign_admin_overlay.mark_as_complete

    expect(assign_admin_overlay).to be_completed
    expect(assign_admin_overlay).to have_no_application_error
  end
end

feature 'Comment Mention Notifications', js: true do
  let(:admin) { FactoryGirl.create :user, admin: true }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal }
  let(:user2) { FactoryGirl.create :user }
  let(:comment_body) { page.find('#comment-body') }

  before do
    Sidekiq::Extensions::DelayedMailer.clear
    paper.collaborators << user2
    paper.save

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
    visit "/papers/#{paper.id}/edit"
  end

  scenario 'sending an email on comment mention' do
    page.find('div.card-content', text: 'Add Authors').click

    within '.comment-board' do
      comment_body.click
      comment_body.set "@#{user2.username}"
      find(".message-comment-buttons", visible: true) # ensure buttons have time to animate in
      click_button 'Post Message'
    end

    sleep 1 # wait for Sidekiq emails
    Sidekiq::Extensions::DelayedMailer.drain
    email = ActionMailer::Base.deliveries.first

    expect(email.to).to eq [user2.email]
    expect(email.body).to include user2.username
  end
end
