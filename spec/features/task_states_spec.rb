require 'rails_helper'

feature 'Task states permissions', js: true do
  let(:submitted_paper) { FactoryGirl.create(:paper, :with_integration_journal, :submitted) }
  let(:submitted_paper_author) { User.first }
  let(:unsubmitted_paper) { FactoryGirl.create(:paper, :unsubmitted, :with_creator, journal: Journal.first) }
  let(:unsubmitted_paper_author) { unsubmitted_paper.creator }
  let(:staff_admin) { FactoryGirl.create(:user) }
  let(:task) do
    FactoryGirl.create(:final_tech_check_task, :with_loaded_card, paper: submitted_paper)
  end
  let(:unsubmitted_paper_task) do
    FactoryGirl.create(:ethics_task, :with_loaded_card, paper: unsubmitted_paper)
  end

  before do
    task.add_participant(submitted_paper_author)
    task.update_column(:completed, true)
    unsubmitted_paper_task.update_column(:completed, true)
    assign_journal_role(Journal.first, staff_admin, :admin)
  end

  context 'Creator Role' do
    context 'for submitted papers' do
      scenario 'has an uneditable task in submitted state' do
        login_as(submitted_paper_author, scope: :user)
        Page.view_task_overlay(submitted_paper, task)
        expect(page).not_to have_content('MAKE CHANGES TO THIS TASK')
        first('.overlay-close-button').click
      end

      scenario 'cannot see other tasks he/she does not own' do
        login_as(submitted_paper_author, scope: :user)
        visit "/papers/#{unsubmitted_paper.id}"
        expect(page).not_to have_content('Ethics')
      end
    end
    context 'for unsubmitted papers' do
      scenario 'has an editable task in unsubmitted state' do
        login_as(unsubmitted_paper_author, scope: :user)
        Page.view_task_overlay(unsubmitted_paper, unsubmitted_paper_task)
        expect(page).to have_content('MAKE CHANGES TO THIS TASK')
      end
    end
  end

  context 'Staff Admin Role' do
    before do
      login_as(staff_admin, scope: :user)
      visit "/"
    end

    context 'for submitted papers' do
      scenario 'has an editable task even in submitted state' do
        Page.view_task_overlay(submitted_paper, task)
        expect(page).to have_content('MAKE CHANGES TO THIS TASK')
      end
    end
    context 'for unsubmitted papers' do
      scenario 'has an editable task in unsubmitted state' do
        Page.view_task_overlay(unsubmitted_paper, unsubmitted_paper_task)
        expect(page).to have_content('MAKE CHANGES TO THIS TASK')
      end
    end
  end
end
