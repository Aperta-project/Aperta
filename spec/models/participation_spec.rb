require 'rails_helper'

describe "Participation" do
  it "will be valid with default factory data" do
    participation = build(:participation)
    expect(participation).to be_valid
  end

  describe "#add_paper_role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:paper) { task.paper }

    context "participant paper old_role already exists" do
      before do
        FactoryGirl.create(:paper_role, :participant, paper: paper, user: user)
      end

      it "will not create another participant paper old_role" do
        expect do
          Participation.create!(task: task, user: user)
        end.to_not change { PaperRole.participants.count }
      end
    end

    context "participant paper old_role does not exist" do
      it "will create a participant paper old_role" do
        expect do
          Participation.create!(task: task, user: user)
        end.to change { PaperRole.participants.count }.by(1)
      end
    end
  end

  describe "#remove_paper_role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:tasks) { FactoryGirl.create_list(:task, 2, paper: paper) }
    let(:paper) { FactoryGirl.create(:paper) }

    context "user is participant on two paper tasks" do
      before do
        FactoryGirl.create(:paper_role, :participant, paper: paper, user: user)
        tasks.each do |task|
          Assignment.where(
            assigned_to: task,
            user: user,
            role: paper.journal.roles.participant
          ).first_or_create!
        end
      end

      it "will not remove the participant paper old_role when destroying one of the participations" do
        expect do
          tasks.first.participations.first.destroy
        end.to_not change { PaperRole.participants.count }
      end
    end

    context "user is participant on one paper task" do
      let(:task) { tasks.first }
      before do
        Assignment.create!(
          user: user,
          assigned_to: task,
          role: task.journal.roles.participant
        )
      end

      it "will remove the participant assignment when destroying the only participation" do
        expect do
          task.participations.first.destroy
        end.to change { task.participants.count }.by(-1)
      end
    end
  end
end
