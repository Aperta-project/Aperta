require 'rails_helper'

feature "Displaying task", js: true do
  let(:admin) { create :user, :site_admin }
  let(:task) { paper.tasks.first }
  let!(:paper) { FactoryGirl.create(:paper_with_task, title: "Assign Admin", creator: admin) }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
    click_link paper.title
    click_link "Workflow"
    find("div.card-content", text: /#{task.title}/).click
  end

  scenario "User visits task's show page" do
    assign_admin_overlay = CardOverlay.new
    expect(assign_admin_overlay).to_not be_completed

    assign_admin_overlay.mark_as_complete

    expect(assign_admin_overlay).to be_completed
    expect(assign_admin_overlay).to have_no_application_error
  end
end
