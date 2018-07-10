# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'support/pages/dashboard_page'
require 'support/pages/paper_page'
require 'support/fake_ihat_service'

feature 'Create a new Manuscript', js: true, sidekiq: :inline! do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt, msword_allowed: true }
  let!(:pdf_only_journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt, msword_allowed: false }

  let!(:papers) { [] }
  let(:dashboard) { DashboardPage.new }

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

  feature 'pre-print overlay card' do
    let(:card) { FactoryGirl.create(:card, journal: journal) }
    let!(:version) do
      FactoryGirl.create :card_version,
                         card: card,
                         required_for_submission: true,
                         published_at: DateTime.current,
                         version: 2,
                         history_entry: 'test'
    end
    let!(:task_template) do
      FactoryGirl.create :task_template, title: "Preprint Posting", phase_template_id: 1, card: card, journal_task_type: nil
    end

    before do
      FeatureFlag.create_with(active: preprint_enabled).find_or_create_by!(name: 'PREPRINT').update!(active: preprint_enabled)
      journal.manuscript_manager_templates.each { |mmt| mmt.update(is_preprint_eligible: is_preprint_eligible) }

      insert_aws_cassette('manuscript-new')
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
    end

    after do
      VCR.eject_cassette
      # Clean up
      # CardVersion.where(card: card.id).destroy_all
      card.reload.destroy!
    end

    feature 'MMTs not pre-print eligible' do
      let(:is_preprint_eligible) { false }

      feature 'and preprint feature flag enabled' do
        let(:preprint_enabled) { true }

        scenario 'do not show preprint offer overlay' do
          expect(page).to_not have_css('.preprint-overlay')
        end
      end

      feature 'and preprint feature flag disabled' do
        let(:preprint_enabled) { true }

        scenario 'do not show preprint offer overlay' do
          expect(page).to_not have_css('.preprint-overlay')
        end
      end
    end

    feature 'MMTs that are preprint-eligible' do
      let(:is_preprint_eligible) { true }

      feature 'and preprint feature flag enabled' do
        let(:preprint_enabled) { true }

        scenario 'show preprint offer overlay' do
          expect(page).to have_css('.preprint-overlay')
        end
      end

      feature 'and preprint feature flag disabled' do
        let(:preprint_enabled) { false }

        scenario 'do not show preprint offer overlay' do
          expect(page).to_not have_css('.preprint-overlay')
        end
      end
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

  scenario 'pdf allowed instructions' do
    login_as(user, scope: :user)
    visit '/'
    find('.button-primary', text: 'CREATE NEW SUBMISSION').click
    dashboard.fill_in_new_manuscript_fields('Paper Title', pdf_only_journal.name, pdf_only_journal.paper_types[0])
    expect(page).to_not have_content('Microsoft Word format (.docx or .doc):')
    expect(page).to have_content('PDF format')
  end
end
