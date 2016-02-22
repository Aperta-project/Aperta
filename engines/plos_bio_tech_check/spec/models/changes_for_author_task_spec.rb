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

  describe '#paper.editable' do
    context 'when the task is created' do
      it 'makes the paper editable' do
        expect { task.save! }.to change { paper.editable }.from(false).to true
      end
    end

    context "when the task's body is updated" do
      before do
        task.save!
        paper.submit_minor_check!(user)
      end

      it 'makes the paper editable' do
        expect { update_task_body! }
          .to change { paper.publishing_state }.from("submitted").to "checking"
      end
    end
  end

  describe "#notify_changes_for_author" do
    it "queues an email to send" do
      expect {
        task.notify_changes_for_author
      }.to change { Sidekiq::Extensions::DelayedMailer.jobs.length }.by 1
    end
  end

  describe '#completed' do
    context "when the task's body is updated" do
      before do
        task.completed = true
        task.save!
      end
      it 'marks the task incomplete' do
        expect{ task.update_attribute 'body', initialTechCheckBody: 'updated' }
          .to change{ task.completed }.from(true).to false
      end
    end

    context 'when the author marks the task complete' do
      it 'stays completed' do
        task.update_attribute 'completed', true
        expect(task.completed).to be true
      end
    end
  end
end
