require 'rails_helper'

feature 'Gradual Engagement', js: true do
  let(:user) { FactoryGirl.create :user }

  before do
    login_as(user, scope: :user)
  end

  let!(:journal) do
    FactoryGirl.create(:journal, :with_roles_and_permissions, :with_default_mmt)
  end

  context 'when viewing the manuscript' do
    context 'as a non-collaborator, ie author, admin' do
      context 'on the first paper view' do
        scenario 'submission process box is shown and contains proper journal
                  title in text on the first visit to the page after creation.
                  The submission process is not automatically shown on
                  subsequent page views' do
          paper = FactoryGirl.create :paper,
                                     :gradual_engagement,
                                     journal: journal,
                                     creator: user
          visit "/papers/#{paper.id}?firstView=true"
          expect(find('#submission-process'))
            .to have_content(paper.journal.name)
          expect(URI.parse(current_url).query).to eq(nil) # ember should remove
          find('#nav-dashboard').click # leave route
          find("#view-paper-#{paper.id}").click # come back
          expect(page).not_to have_selector('#submission-process.show-process')
        end

        scenario 'the X in the submission process box closes the box' do
          paper = FactoryGirl.create :paper,
                                     :gradual_engagement,
                                     journal: journal,
                                     creator: user
          visit "/papers/#{paper.id}?firstView=true"
          expect(find('#submission-process'))
          find('#sp-close').click
          expect(page).not_to have_selector('#submission-process.show-process')
        end
      end
    end

    context 'and the paper has never been submitted and still has submittable
             tasks' do
      scenario 'the sidebar submission text shows manuscript ID message and INITIAL submission state information' do
        paper = FactoryGirl.create :paper,
                                   :with_tasks,
                                   :gradual_engagement,
                                   journal: journal,
                                   creator: user
        visit "/papers/#{paper.id}"
        expect(find('#submission-process-toggle-box'))
          .not_to have_content(paper.journal.name)
        expect(find('.gradual-engagement-presubmission-messaging.initial'))
          .to have_content('Please provide the following information to submit')
        expect(find('.gradual-engagement-presubmission-messaging.initial'))
          .to have_content('Initial Submission')
        expect(page).to have_selector('#submission-process-toggle')
        expect(page).to have_link('Submission Process Overview')
        click_link 'Submission Process Overview'

        expect(find('#submission-process'))
        find('#sp-close').click
        expect(page).not_to have_selector('#submission-process')
      end
    end

    context 'when the paper is not gradual engagement' do
      scenario 'and there are tasks to complete' do
        paper = FactoryGirl.create :paper,
                                   :with_tasks,
                                   creator: user,
                                   journal: journal,
                                   gradual_engagement: false
        visit "/papers/#{paper.id}"
        expect(page).to have_text('You must complete the following tasks before submitting')
      end
    end

    context 'and the paper has never been submitted and is submittable' do
      scenario 'the sidebar submission text shows journal name and message to
                fill out info and INITIAL submission state information' do
        paper = FactoryGirl.create :paper,
                                   :gradual_engagement,
                                   journal: journal,
                                   creator: user
        visit "/papers/#{paper.id}"
        expect(find('.ready-to-submit.initial'))
          .to have_content('Your manuscript is ready for Initial Submission')
      end
    end

    context 'and the paper has been invited for full submission and still has
             submittable tasks' do
      scenario 'the sidebar submission text manuscript ID and submission process overview link
                and FULL submission state information' do
        paper = FactoryGirl
                .create :paper,
                        :with_tasks,
                        :gradual_engagement,
                        journal: journal,
                        creator: user,
                        publishing_state: :invited_for_full_submission
        visit "/papers/#{paper.id}"
        expect(find('#submission-process-toggle-box'))
          .not_to have_content(paper.journal.name)
        expect(find('.gradual-engagement-presubmission-messaging.full'))
          .to have_content('Please provide the following information to submit
            your manuscript for Full Submission')
        expect(page).to have_selector('#submission-process-toggle')
        expect(page).to have_link('Submission Process Overview')
        click_link 'Submission Process Overview'

        expect(find('#submission-process'))
        find('#main-content').click
        expect(page).not_to have_selector('#submission-process')
      end
    end

    context 'and the paper is in revision and has incomplete submittable
      tasks' do
      scenario 'the sidebar submission text shows journal name and message to
                fill out remaining tasks.' do
        paper = FactoryGirl.create :paper,
                                   :with_tasks,
                                   :gradual_engagement,
                                   journal: journal,
                                   creator: user,
                                   publishing_state: :in_revision
        visit "/papers/#{paper.id}"
        expect(find('.gradual-engagement-presubmission-messaging'))
          .to have_content('Please provide the following information to submit
            your manuscript.')
        expect(page).not_to have_selector('#submission-process-toggle')
        expect(page).not_to have_link('Submission Process Overview')
      end
    end

    context 'and the paper is in revision and is ready for submission' do
      scenario 'the sidebar submission text shows journal name and message to
                fill out info FULL submission state information' do
        paper = FactoryGirl.create :paper,
                                   :gradual_engagement,
                                   journal: journal,
                                   creator: user,
                                   publishing_state: :in_revision
        visit "/papers/#{paper.id}"
        expect(find('.ready-to-submit'))
          .to have_content('Your manuscript is ready for Submission')
        expect(page).not_to have_selector('#submission-process-toggle')
      end
    end

    context 'when viewing a gradual engagment paper in a pre full-submission
      state' do
      scenario 'the circled ? toggles the visibility of the submission process
                box' do
        paper = FactoryGirl.create :paper,
                                   :gradual_engagement,
                                   journal: journal,
                                   creator: user
        visit "/papers/#{paper.id}"
        expect(page).not_to have_selector('#submission-process.show-process')
        find('#submission-process-toggle').click
        expect(find('#submission-process'))
        find('#submission-process-toggle').click
        expect(page).not_to have_selector('#submission-process.show-process')
      end
    end
  end

  context 'when submitting' do
    context 'when a paper is in a gradual engagement workflow' do
      context 'On initial submission' do
        let(:paper) do
          FactoryGirl.create(
            :paper,
            :gradual_engagement,
            journal: journal,
            creator: user
          )
        end

        scenario 'sees initial submit confirmation overlay on submit' do
          expect(paper.publishing_state).to eq('unsubmitted')
          visit "/papers/#{paper.id}"
          find('#sidebar-submit-paper').click
          find('.submit-action-buttons .button-submit-paper').click
          expect(find('#initial-submit-message'))
          expect(paper.reload.publishing_state).to eq('initially_submitted')
        end
      end

      context 'after invitation (on full submit) ' do
        let(:paper) do
          FactoryGirl.create(
            :paper,
            :gradual_engagement,
            journal: journal,
            creator: user,
            publishing_state: :invited_for_full_submission
          )
        end

        scenario 'user sees full submit confirmation overlay' do
          expect(paper.publishing_state).to eq('invited_for_full_submission')
          visit "/papers/#{paper.id}"
          find('#sidebar-submit-paper').click
          find('.submit-action-buttons .button-submit-paper').click
          expect(find('#full-submit-message'))
          expect(paper.reload.publishing_state).to eq('submitted')
          expect(page).not_to have_selector('#submission-process.show-process')
          expect(page).not_to have_selector('#submission-process-toggle')
        end
      end

      context 'when submitting after revision' do
        let(:paper) do
          FactoryGirl.create(
            :paper,
            :gradual_engagement,
            journal: journal,
            creator: user,
            publishing_state: :in_revision
          )
        end

        scenario 'user sees full submit confirmation overlay' do
          expect(paper.publishing_state).to eq('in_revision')
          visit "/papers/#{paper.id}"
          find('#sidebar-submit-paper').click
          find('.submit-action-buttons .button-submit-paper').click
          expect(find('#standard-submit-message'))
          expect(paper.reload.publishing_state).to eq('submitted')
        end
      end
    end

    context 'when a paper is NOT in a gradual engagement workflow' do
      let(:paper) do
        FactoryGirl.create(
          :paper,
          creator: user,
          journal: journal,
          gradual_engagement: false
        )
      end

      scenario 'User sees standard submit confirmation overlay' do
        expect(paper.publishing_state).to eq('unsubmitted')
        visit "/papers/#{paper.id}"
        find('#sidebar-submit-paper').click
        find('.submit-action-buttons .button-submit-paper').click
        expect(find('#standard-submit-message'))
        expect(paper.reload.publishing_state).to eq('submitted')
      end
    end
  end
end
