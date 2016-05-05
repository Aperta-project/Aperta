require 'rails_helper'

feature 'Create a new Manuscript', js: true, sidekiq: :inline! do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let(:inactive_paper_count) { 0 }
  let(:active_paper_count) { 0 }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let!(:papers) { [] }

  let(:dashboard) { DashboardPage.new }

  scenario 'failure' do
    login_as(user, scope: :user)
    visit '/'
    find('.button-primary', text: 'CREATE NEW SUBMISSION').click

    attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false

    expect(page).to have_content('Paper type can\'t be blank')
  end

  def paper_src
      paper = Paper.find_by(title: 'Paper Title')
      if paper
        paper.latest_version[:source]
      end
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
        sentinel: proc { paper_src }
      )

      visit "/papers/#{Paper.last.id}"
      expect(PaperPage.new).to_not be_loading_paper
    end
  end
end
