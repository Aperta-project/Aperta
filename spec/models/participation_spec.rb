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
      before { FactoryGirl.create(:paper_role, :participant, paper: paper, user: user) }

      it "will not create another participant paper old_role" do
        expect { Participation.create!(task: task, user: user) }.to_not change { PaperRole.participants.count }
      end
    end

    context "participant paper old_role does not exist" do
      it "will create a participant paper old_role" do
        expect { Participation.create!(task: task, user: user) }.to change { PaperRole.participants.count }.by(1)
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
          FactoryGirl.create(:participation, task: task, user: user)
        end
      end

      it "will not remove the participant paper old_role when destroying one of the participations" do
        expect { tasks.first.participations.first.destroy }.to_not change { PaperRole.participants.count }
      end
    end

    context "user is participant on one paper task" do
      before do
        FactoryGirl.create(:paper_role, :participant, paper: paper, user: user)
        FactoryGirl.create(:participation, task: tasks.first, user: user)
      end

      it "will remove the participant paper old_role when destroying the only participation" do
        expect { tasks.first.participations.first.destroy }.to change { PaperRole.participants.count }.by(-1)
      end
    end
  end
end
