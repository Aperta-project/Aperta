require 'rails_helper'

describe ChangesForAuthorTask do
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
end
