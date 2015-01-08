require 'rails_helper'

feature "Displaying task", js: true do
  let(:admin) { create :user, :site_admin }
  let(:author) { create :user }
  let!(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, creator: author }
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
