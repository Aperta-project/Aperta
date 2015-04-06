require "rails_helper"

feature "Add editor invitation email template", js: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { create :journal }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:admin_page) { AdminDashboardPage.visit }
  let!(:journal_page) { admin_page.visit_journal(journal) }

  scenario "adding invitation template" do
    body = "Expected addition to the email body"
    journal_page.update_editor_invite_email_template body
    expect(journal_page.editor_invite_email_template_saved?).to eq(true)
    expect(journal_page.view_editor_invite_email_template).to eq body
    expect(journal_page).to have_no_application_error
  end
end
