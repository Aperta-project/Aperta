require 'rails_helper'

describe Invitation do
  subject(:invitation) { FactoryGirl.build :invitation, task: task }
  let(:paper) { FactoryGirl.create(:paper, :with_author) }
  let(:task) { FactoryGirl.create :invitable_task, paper: paper }

  describe ".invited" do
    let!(:open_invitation_1) { FactoryGirl.create(:invitation, :invited) }
    let!(:open_invitation_2) { FactoryGirl.create(:invitation, :invited) }
    let!(:accepted_invitation) { FactoryGirl.create(:invitation, state: 'accepted') }

    it "returns invitations that are in the 'invited' state" do
      expect(Invitation.invited).to include(open_invitation_1, open_invitation_2)
    end

    it "does not include invitations that are not in the 'invited' state" do
      expect(Invitation.invited).to_not include(accepted_invitation)
    end
  end

  describe 'validations' do
    it 'is valid' do
      expect(invitation.valid?).to be(true)
    end

    it 'requires an invitee_role' do
      invitation.task = nil
      invitation.invitee_role = nil
      expect(invitation.valid?).to be(false)
    end
  end

  describe 'before validation' do
    let(:task_class) do
      Class.new(Task) do
        def self.model_name
          ActiveModel::Name.new(self, nil, "SomeTaskSubclass")
        end

        def invitee_role
          'Superduperiffic'
        end
      end
    end

    it 'sets the invitee_role to the invitee_role defined by the task' do
      invitation.task = task_class.new
      expect do
        invitation.valid?
      end.to change { invitation.invitee_role }.to 'Superduperiffic'
    end

    it 'does not set the invitee_role when there is no task' do
      invitation.task = nil
      expect do
        invitation.valid?
      end.to_not change { invitation.invitee_role }
    end
  end

  describe '#create' do
    it "belongs to the paper's latest decision" do
      invitation.save!
      expect(paper.decisions.latest.invitations).to include invitation
    end

    context 'when there is more than one decision' do
      it 'is associated with the latest decision' do
        latest_decision = FactoryGirl.create :decision, paper: paper
        invitation.save!
        latest_revision_number = (paper.decisions.pluck :revision_number).max
        expect(invitation.decision).to eq latest_decision
        expect(invitation.decision).to eq paper.decisions.latest
        expect(invitation.decision.revision_number).to eq latest_revision_number
      end
    end
  end

  describe '#destroy' do
    it "calls #after_destroy hook" do
      expect(task).to receive(:invitation_rescinded).with invitation
      invitation.destroy!
    end
  end

  describe "#invite!" do
    it "is invited by default" do
      expect(task).to receive(:invite_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_invited).with(invitation)
      invitation.invite!
    end

    it "prevents transition to invited" do
      allow(invitation).to receive(:invite_allowed?).and_return(false)
      expect { invitation.invite! }.to raise_exception(AASM::InvalidTransition)
      expect(invitation.invited?).to be_falsey
    end

    it "adds the author list to invitation.information" do
      authors_list = TahiStandardTasks::AuthorsList.authors_list(paper)
      expect(authors_list).to_not be_empty
      invitation.invite!
      expect(invitation.information)
        .to eq("Here are the authors on the paper:\n\n#{authors_list}")
    end
  end

  describe "#accept!" do
    it "sends an old_role invitation email" do
      invitation.invite!
      expect(task).to receive(:accept_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_accepted).with(invitation)
      invitation.accept!
    end

    it "prevents transition to accepted" do
      invitation.invite!
      expect(task).to receive(:accept_allowed?) .with(invitation).and_return(false)
      expect { invitation.accept! }.to raise_exception(AASM::InvalidTransition)
      invitation.run_callbacks(:commit)
      expect(invitation.invited?).to be_truthy
      expect(invitation.accepted?).to be_falsey
    end
  end

  describe "#reject!" do
    it "calls the the invitation rejection callback" do
      invitation.invite!
      expect(task).to receive(:reject_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_rejected).with(invitation)
      invitation.reject!
    end

    it "prevents transition to rejected" do
      invitation.invite!
      expect(task).to receive(:reject_allowed?) .with(invitation).and_return(false)
      expect { invitation.reject! }.to raise_exception(AASM::InvalidTransition)
      invitation.run_callbacks(:commit)
      expect(invitation.invited?).to be_truthy
      expect(invitation.rejected?).to be_falsey
    end
  end

  describe "#recipient_name" do
    let(:invitee) { FactoryGirl.build(:user, first_name: "Ben", last_name: "Howard") }

    before do
      invitation.invitee = invitee
      invitation.email = "ben.howard@example.com"
    end

    context "and there is an invitee" do
      it "returns the's invitee's full_name" do
        expect(invitation.recipient_name).to eq("Ben Howard")
      end
    end

    context "and there is no invitee" do
      it "returns the email that the invitation is for" do
        invitation.invitee = nil
        expect(invitation.recipient_name).to eq("ben.howard@example.com")
      end
    end
  end

  describe 'Invitation.find_uninvited_users_for_paper' do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create :invitable_task, paper: paper }
    let(:no_invite_user) { FactoryGirl.create(:user) }
    let(:pending_invite_user) { FactoryGirl.create(:user) }
    let(:accepted_invite_user) { FactoryGirl.create(:user) }
    let(:rejected_invite_user) { FactoryGirl.create(:user) }
    let(:all_users) do
      [no_invite_user,
       pending_invite_user,
       accepted_invite_user,
       rejected_invite_user
      ]
    end
    context 'Users with invites in various states' do
      before do
        FactoryGirl.create :invitation, :invited, task: task, invitee: pending_invite_user
        FactoryGirl.create :invitation, :accepted, task: task, invitee: accepted_invite_user
        FactoryGirl.create :invitation, :rejected, task: task, invitee: rejected_invite_user
      end

      let(:result) { Invitation.find_uninvited_users_for_paper(all_users, paper) }
      it "doesn't filter out the user without any invite" do
        expect(result).to contain_exactly(no_invite_user)
      end
      it "filters out the user with a pending invite" do
        expect(result).to_not include(pending_invite_user)
      end
      it "filters out the user with an accepted invite" do
        expect(result).to_not include(accepted_invite_user)
      end
      it "filters out the user with a rejected invite" do
        expect(result).to_not include(rejected_invite_user)
      end

      context "When invites belong to a previous decision" do
        before do
          paper.decisions.create!
        end
        it "doesn't filter users based on the old invites" do
          expect(result).to contain_exactly(
            no_invite_user,
            pending_invite_user,
            rejected_invite_user,
            accepted_invite_user
          )
        end
      end
    end
  end

  describe "#where_email_matches" do
    let(:email) { "turtle@turtles.com" }
    let!(:invitation_1) { create :invitation, email: email }
    let!(:invitation_2) { create :invitation, email: "turtle <#{email}>" }
    let!(:invitation_3) { create :invitation, email: "another@email.com" }

    it "returns invitiations where the email matches the supplied argument" do
      invitations = Invitation.where_email_matches email
      expect(Invitation.count).to eq 3
      expect(invitations.map(&:id)).to match [invitation_1.id, invitation_2.id]
    end
  end
end
