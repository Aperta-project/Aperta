require 'spec_helper'

feature "Displaying task", js: true do
  let(:admin) { create :user, admin: true }
  let(:author) { create :user }
  let!(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create!, user: author }
  let(:task) { Task.where(title: "Assign Admin").first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  scenario "User visits task's show page" do
    assign_admin_overlay = CardOverlay.visit [task.paper, task]
    expect(assign_admin_overlay).to_not be_completed

    assign_admin_overlay.mark_as_complete
    assign_admin_overlay.reload

    expect(assign_admin_overlay).to be_completed
  end

end
