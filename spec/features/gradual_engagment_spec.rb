require 'rails_helper'

feature 'Gradual Engagement', js: true do
  let(:user) { FactoryGirl.create :user }

  before do
    login_as(user, scope: :user)
  end

  context 'when submitting' do
    context 'when a paper is in a gradual engagement workflow' do
      context 'On initial submission' do
        let(:paper) do
          FactoryGirl.create :paper, creator: user, gradual_engagement: true
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
          FactoryGirl.create :paper,
                             creator: user,
                             gradual_engagement: true,
                             publishing_state: :invited_for_full_submission
        end

        scenario 'user sees full submit confirmation overlay' do
          expect(paper.publishing_state).to eq('invited_for_full_submission')
          visit "/papers/#{paper.id}"
          find('#sidebar-submit-paper').click
          find('.submit-action-buttons .button-submit-paper').click
          expect(find('#full-submit-message'))
          expect(paper.reload.publishing_state).to eq('submitted')
        end
      end

      context 'when submitting after revision' do
        let(:paper) do
          FactoryGirl.create :paper,
                             creator: user,
                             gradual_engagement: true,
                             publishing_state: :in_revision
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
        FactoryGirl.create :paper, creator: user, gradual_engagement: false
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
