require "rails_helper"

describe ParticipationFactory do
  let(:task) { FactoryGirl.create(:task) }

  describe ".create" do
    let(:assignee) { FactoryGirl.create(:user) }
    let(:assigner) { FactoryGirl.create(:user) }

    context "when the assignee is already a participant" do
      before do
        Participation.create(task: task, user: assignee)
      end

      it "does not create a participation" do
        expect {
          ParticipationFactory.create(task: task, assignee: assignee, assigner: assigner)
        }.to_not change(Participation, :count)
      end
    end

    context "assigner and assignee are different" do
      it "creates a participation that does not notify the assigner" do
        participation = ParticipationFactory.create(task: task, assignee: assignee, assigner: assigner)
        expect(participation.notify_requester).to eq(false)
      end

      it "emails the assignee" do
        expect(UserMailer).to receive_message_chain("delay.add_participant")
        ParticipationFactory.create(task: task, assignee: assignee, assigner: assigner)
      end
    end

    context "assigner is the same as the assignee" do
      let(:user) { FactoryGirl.create(:user) }

      it "creates a participation that notifies the assigner" do
        participation = ParticipationFactory.create(task: task, assignee: user, assigner: user)
        expect(participation.notify_requester).to eq(true)
      end

      it "does not email the assignee" do
        expect(UserMailer).to_not receive(:delay)
        ParticipationFactory.create(task: task, assignee: user, assigner: user)
      end
    end
  end
end
