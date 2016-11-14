require 'rails_helper'

describe PlosBioTechCheck::ChangesForAuthorTask do
  let(:paper) do
    FactoryGirl.create :paper, :submitted, journal: journal
  end
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:task) { FactoryGirl.build :changes_for_author_task, paper: paper }
  let(:user) { FactoryGirl.create :user }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#notify_changes_for_author" do
    it "queues an email to send" do
      expect { task.notify_changes_for_author }
        .to change { Sidekiq::Extensions::DelayedMailer.jobs.length }.by 1
    end
  end

  describe '#completed' do
    context 'when the author marks the task complete' do
      it 'stays completed' do
        task.update_attribute 'completed', true
        expect(task.completed).to be true
      end
    end
  end

  describe '#submit_tech_check: an author submitting response to tech check' do
    subject(:submit_tech_check) do
      task.submit_tech_check!(submitted_by: user)
    end

    let(:paper) { FactoryGirl.create :paper, :checking, journal: journal }

    it 'completes the task' do
      expect { submit_tech_check }.to change { task.completed }.to(true)
    end

    it 'tells the paper that a minor check has been submitted' do
      expect do
        submit_tech_check
      end.to change { paper.publishing_state }.from('checking').to('submitted')
    end

    context 'when the paper is in an invalid state' do
      let(:paper) { FactoryGirl.create :paper, :submitted, journal: journal }

      it 'raises an AASM::InvalidTransition exception' do
        expect do
          submit_tech_check
        end.to raise_error(AASM::InvalidTransition, /cannot transition/)
      end
    end

    context 'when the minor check has been submitted successfully' do
      let!(:initial_tech_check_task) do
        FactoryGirl.create(:initial_tech_check_task, paper: paper)
      end

      it 'increments the round of any InitialTechCheckTask(s) on the paper' do
        expect do
          submit_tech_check
        end.to change { initial_tech_check_task.reload.round }.by(1)
      end

      it <<-DESC.strip_heredoc do
        queues up emails to notify admins that the author have responded
        to tech check
      DESC
        skip "Paper#admins implementation is wrong"
      end

      it 'creates an Activity feed item' do
        expect do
          submit_tech_check
        end.to change { Activity.count }
        expect(Activity.find_by(
          feed_name: 'manuscript',
          activity_key: 'paper.tech_fixed',
          subject: task.paper,
          user: user,
          message: 'Author tech fixes were submitted'
        )).to be
      end

      it 'returns true' do
        expect(submit_tech_check).to be true
      end
    end

    context 'when the minor check has not been submitted successfully' do
      before do
        allow(task.paper).to receive(:submit_minor_check!)
          .with(user)
          .and_return false
      end

      it 'returns false' do
        expect(submit_tech_check).to be false
      end
    end
  end
end
