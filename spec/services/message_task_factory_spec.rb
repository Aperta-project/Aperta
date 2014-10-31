require 'spec_helper'

describe TaskFactory::MessageTaskFactory do

  describe "#build" do
    context "an existing paper and a user" do
      let(:user) { FactoryGirl.create :user }
      let(:paper) { FactoryGirl.create :paper, :with_tasks }
      let(:phase) { paper.phases.first }

      let(:title) { "A subject." }
      let(:participant_ids) { [user.id] }
      let(:msg_body) { "It's a test body." }
      let(:msg_params) do
        { title: title,
          body: msg_body,
          participant_ids: participant_ids,
          role: 'user',
          phase_id: phase.id }
      end
      let(:result) do
        TaskFactory::MessageTaskFactory.build(msg_params, user)
      end

      context "with a message subject and body" do
        it "returns a new MessageTask with a subject" do
          expect(result.title).to eq(title)
        end

        it "creates a new Comment for the MessageTask" do
          expect(result.comments.count).to eq 1
          c = result.comments.first
          expect(c.body).to eq(msg_body)
          expect(c.commenter).to eq(user)
        end
      end

      context "with no message body" do
        let(:msg_body) { nil }
        it "creates the MessageTask, but no comment" do
          expect(result.title).to eq(title)
          expect(result.comments.count).to eq(0)
        end
      end
    end
  end
end
