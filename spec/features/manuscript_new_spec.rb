require 'rails_helper'

feature 'Create a new Manuscript', js: true, sidekiq: :inline! do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let(:inactive_paper_count) { 0 }
  let(:active_paper_count) { 0 }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let!(:papers) { [] }

  let(:dashboard) { DashboardPage.new }

  scenario 'failure' do
    with_aws_cassette('manuscript-new') do
      login_as(user, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click

      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_equations.docx'), visible: false

      expect(page).to have_content('Paper type can\'t be blank')
    end
  end

  def paper_has_uploaded_manuscript
    paper = Paper.find_by(title: 'Paper Title')
    paper.try(:file).try(:url)
  end

  scenario 'success' do
    with_aws_cassette('manuscript-new') do
      login_as(user, scope: :user)
      visit '/'

      find('.button-primary', text: 'CREATE NEW SUBMISSION').click

      dashboard.fill_in_new_manuscript_fields('Paper Title', journal.name, journal.paper_types[0])
      expect(page).to have_css('.paper-new-valid-icon', count: 3)

      dashboard.upload_file(
        element_id: 'upload-files',
        file_name: 'about_equations.docx',
        sentinel: proc { paper_has_uploaded_manuscript },
        process_before_upload: true
      )

      FakeIhatService.complete_paper_processing!(
        paper_id: Paper.last.id,
        user_id: user.id
      )

      visit "/papers/#{Paper.last.id}"

      expect(PaperPage.new).to be_not_loading_paper
    end
  end
end
