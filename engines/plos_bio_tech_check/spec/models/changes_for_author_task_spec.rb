require 'rails_helper'

describe PlosBioTechCheck::ChangesForAuthorTask do
  let(:paper) do
    FactoryGirl.create :paper, :with_integration_journal, :submitted
  end
  let(:task) { FactoryGirl.build :changes_for_author_task, paper: paper }
  let(:user) { FactoryGirl.create :user }

  def update_task_body!
    task.assign_attributes body: { initialTechCheckBody: 'updated' }
    task.save!
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
