require 'rails_helper'
require 'support/pages/dashboard_page'
require 'support/pages/paper_page'
require 'support/fake_ihat_service'

feature 'Create a new Manuscript', js: true, sidekiq: :inline! do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let(:inactive_paper_count) { 0 }
  let(:active_paper_count) { 0 }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt, pdf_allowed: true, msword_allowed: true }
  let!(:pdf_only_journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt, pdf_allowed: true, msword_allowed: false }
  let!(:msword_only_journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt, pdf_allowed: false, msword_allowed: true }

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

  scenario 'MMTs not pre-print eligible and preprint feature flag enabled do not show preprint offer overlay' do
    FeatureFlag.create!(name: 'PREPRINT', active: true)
    journal.manuscript_manager_templates.each { |mmt| mmt.update(is_preprint_eligible: false) }
    with_aws_cassette('manuscript-new') do
      login_as(user, scope: :user)
      visit '/'

      find('.button-primary', text: 'CREATE NEW SUBMISSION').click

      dashboard.fill_in_new_manuscript_fields('Paper Title', journal.name, journal.paper_types[0])
      expect(page).to have_css('.paper-new-valid-icon', count: 3)

      dashboard.upload_file(
        element_id: 'upload-files',
        file_name: 'about_equations.docx',
        sentinel: proc { paper_has_uploaded_manuscript }
      )

      expect(page).to_not have_css('.preprint-overlay')
    end
  end

  scenario 'MMTs not pre-print eligible and preprint feature flag disabled do not show preprint offer overlay' do
    FeatureFlag.create!(name: 'PREPRINT', active: false)
    journal.manuscript_manager_templates.each { |mmt| mmt.update(is_preprint_eligible: false) }
    with_aws_cassette('manuscript-new') do
      login_as(user, scope: :user)
      visit '/'

      find('.button-primary', text: 'CREATE NEW SUBMISSION').click

      dashboard.fill_in_new_manuscript_fields('Paper Title', journal.name, journal.paper_types[0])
      expect(page).to have_css('.paper-new-valid-icon', count: 3)

      dashboard.upload_file(
        element_id: 'upload-files',
        file_name: 'about_equations.docx',
        sentinel: proc { paper_has_uploaded_manuscript }
      )

      expect(page).to_not have_css('.preprint-overlay')
    end
  end

  scenario 'MMTs that are preprint-eligible and preprint feature flag enabled show preprint offer overlay' do
    FeatureFlag.create!(name: 'PREPRINT', active: true)
    journal.manuscript_manager_templates.each { |mmt| mmt.update(is_preprint_eligible: true) }
    c = FactoryGirl.create :card, journal: journal
    FactoryGirl.create :card_version,
      card: c,
      required_for_submission: true,
      published_at: DateTime.current,
      version: 2,
      history_entry: 'test'
    FactoryGirl.create :task_template, title: "Preprint Posting", phase_template_id: 1, card: c, journal_task_type: nil

    with_aws_cassette('manuscript-new') do
      login_as(user, scope: :user)
      visit '/'

      find('.button-primary', text: 'CREATE NEW SUBMISSION').click

      dashboard.fill_in_new_manuscript_fields('Paper Title', journal.name, journal.paper_types[0])
      expect(page).to have_css('.paper-new-valid-icon', count: 3)

      dashboard.upload_file(
        element_id: 'upload-files',
        file_name: 'about_equations.docx',
        sentinel: proc { paper_has_uploaded_manuscript }
      )

      expect(page).to have_css('.preprint-overlay')
    end
  end

  scenario 'MMTs that are preprint-eligible and preprint feature flag disabled do not show preprint offer overlay' do
    FeatureFlag.create!(name: 'PREPRINT', active: false)
    journal.manuscript_manager_templates.each { |mmt| mmt.update(is_preprint_eligible: true) }
    c = FactoryGirl.create :card, journal: journal
    FactoryGirl.create :card_version,
                       card: c,
                       required_for_submission: true,
                       published_at: DateTime.current,
                       version: 2,
                       history_entry: 'test'
    FactoryGirl.create :task_template, title: "Preprint Posting", phase_template_id: 1, card: c, journal_task_type: nil

    with_aws_cassette('manuscript-new') do
      login_as(user, scope: :user)
      visit '/'

      find('.button-primary', text: 'CREATE NEW SUBMISSION').click

      dashboard.fill_in_new_manuscript_fields('Paper Title', journal.name, journal.paper_types[0])
      expect(page).to have_css('.paper-new-valid-icon', count: 3)

      dashboard.upload_file(
        element_id: 'upload-files',
        file_name: 'about_equations.docx',
        sentinel: proc { paper_has_uploaded_manuscript }
      )

      expect(page).to_not have_css('.preprint-overlay')
    end
  end

  scenario 'pdf and msword allowed instructions' do
    login_as(user, scope: :user)
    visit '/'
    find('.button-primary', text: 'CREATE NEW SUBMISSION').click
    dashboard.fill_in_new_manuscript_fields('Paper Title', journal.name, journal.paper_types[0])
    expect(page).to have_content('Microsoft Word format (.docx or .doc):')
    expect(page).to have_content('PDF format:')
  end

  scenario 'msword allowed instructions' do
    login_as(user, scope: :user)
    visit '/'
    find('.button-primary', text: 'CREATE NEW SUBMISSION').click
    dashboard.fill_in_new_manuscript_fields('Paper Title', msword_only_journal.name, msword_only_journal.paper_types[0])
    expect(page).to have_content('Microsoft Word format (.docx or .doc):')
    expect(page).to_not have_content('PDF format:')
  end

  scenario 'pdf allowed instructions' do
    login_as(user, scope: :user)
    visit '/'
    find('.button-primary', text: 'CREATE NEW SUBMISSION').click
    dashboard.fill_in_new_manuscript_fields('Paper Title', pdf_only_journal.name, pdf_only_journal.paper_types[0])
    expect(page).to_not have_content('Microsoft Word format (.docx or .doc):')
    expect(page).to have_content('PDF format:')
  end
end
