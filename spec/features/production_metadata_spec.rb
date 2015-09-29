require 'rails_helper'

feature 'Production Metadata Card', js: true do
  let(:admin) { create :user, site_admin: true, first_name: 'Admin' }
  let(:author) { create :user, first_name: 'Author' }
  let!(:paper)  { create :paper, :with_tasks, creator: author }
  let(:production_metadata_task) do
    create :production_metadata_task, phase: paper.phases.first
  end

  before do
    login_as admin
    visit "/papers/#{paper.id}/tasks/#{production_metadata_task.id}"
  end

  describe 'completing a Production Metadata card' do
    describe 'adding a volumne number' do
      it 'does not allows alphas to be entered' do
        fill_in('production_metadata.volumeNumber', with: 'alpha characters')
        inputs = page.all('input')
        volume_number = inputs[1]
        expect(volume_number.value).not_to eq 'alpha characters'
      end

      it 'allows numbers to be entered' do
        fill_in('production_metadata.volumeNumber', with: 1234)
        inputs = page.all('input')
        volume_number = inputs[1]
        expect(volume_number.value).to eq '1234'
      end
    end

    describe 'adding an issue number' do
      it 'does not allows alphas to be entered' do
        fill_in('production_metadata.issueNumber', with: 'alpha characters')
        inputs = page.all('input')
        issue_number = inputs[2]
        expect(issue_number.value).not_to eq 'alpha characters'
      end

      it 'allows numbers to be entered' do
        fill_in('production_metadata.issueNumber', with: 1234)
        inputs = page.all('input')
        issue_number = inputs[2]
        expect(issue_number.value).to eq '1234'
      end
    end

    describe 'filling in the entire card' do
      it 'persists information' do
        find("input[name='production_metadata.volumeNumber']").set '1234'
        page.execute_script "$(\"input[name='production_metadata.volumeNumber']\").trigger('change')"

        find("input[name='production_metadata.issueNumber']").set '5678'
        page.execute_script "$(\"input[name='production_metadata.issueNumber']\").trigger('change')"

        find("textarea[name='production_metadata.productionNotes']").set 'Too cool for school.'
        page.execute_script "$(\"textarea[name='production_metadata.productionNotes']\").trigger('change')"

        find("input[name='production_metadata.publicationDate']").set '08/31/2015'
        page.execute_script "$(\"input[name='production_metadata.publicationDate']\").trigger('change')"

        first('.overlay-close-button').click
        wait_for_ajax
        visit "/papers/#{paper.id}/tasks/#{production_metadata_task.id}"
        find('label', text: 'Volume Number')
        expect(find("input[name='production_metadata.publicationDate']").value).to eq '08/31/2015'
        expect(find("input[name='production_metadata.volumeNumber']").value).to eq '1234'
        expect(find("input[name='production_metadata.issueNumber']").value).to eq '5678'
        expect(find("textarea[name='production_metadata.productionNotes']").value).to eq 'Too cool for school.'
      end
    end
  end
end
