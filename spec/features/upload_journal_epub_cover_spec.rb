require 'rails_helper'

feature "Upload default ePub cover for journal", js: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { create :journal, :with_roles_and_permissions }

  before do
    login_as(admin, scope: :user)
  end

  let(:admin_page) { AdminDashboardPage.visit }

  scenario "uploading an ePub cover" do
    admin_page.visit_journal(journal)
    admin_page.attach_and_upload_cover_image(journal, 'yeti.jpg')
    expect(page).to have_content("yeti.jpg")
  end
end
