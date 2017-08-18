require 'rails_helper'

feature "Displaying task", js: true do
  let(:admin) { create :user, :site_admin }
  let(:task) { paper.tasks.first }
  let!(:paper) do
    FactoryGirl.create(:paper_with_task,
      :with_integration_journal,
      creator: admin,
      task_params: {
        type: 'AdHocTask',
        title: "Some Task"
      })
  end

  before do
    login_as(admin, scope: :user)
    visit "/"
    click_link paper.title
    click_link "Workflow"
    find(".card-title", text: /#{task.title}/).click
  end

  scenario "User visits task's show page" do
    assign_admin_overlay = CardOverlay.new
    expect(assign_admin_overlay).to_not be_completed

    assign_admin_overlay.mark_as_complete

    expect(assign_admin_overlay).to be_completed
    expect(assign_admin_overlay).to have_no_application_error
  end
end
