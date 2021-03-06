# coding: utf-8

# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe Invitation do
  subject(:invitation) { FactoryGirl.build :invitation, task: task }
  let(:paper) { FactoryGirl.create(:paper, :submitted_lite, :with_author) }
  let(:task) { FactoryGirl.create :invitable_task, paper: paper }
  let!(:invite_letter_template) { FactoryGirl.create(:letter_template, :academic_editor_invite, journal: paper.journal) }

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

    it 'requires a valid email address sans new line' do
      invitation.email = "foo@bar.com\nwat"
      expect(invitation).to_not be_valid
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
    it "belongs to the paper's draft decision" do
      invitation.save!
      expect(paper.draft_decision.invitations).to include invitation
    end

    it "creates a token on create" do
      expect(invitation.token).to be_nil
      expect do
        invitation.save!
      end.to change { invitation.token }
      expect(invitation.token).to_not be_nil
    end

    context 'when there is more than one decision' do
      let!(:completed_decision) { FactoryGirl.create :decision, paper: paper }
      let(:draft_decision) { paper.draft_decision }

      it 'the new invitation belongs to the draft decision' do
        expect(paper.decisions.count).to eq 2
        invitation.save!
        expect(invitation.decision).to eq draft_decision
      end
    end

    it 'strips whitespace in email addresses' do
      invitation.email = ' foo@example.com '
      expect(invitation.email).to eq('foo@example.com')
      invitation.save!
      invitation.reload
      expect(invitation.email).to eq('foo@example.com')
    end
  end

  describe '#rescind!' do
    it "sets the state to 'rescinded' from 'invited'" do
      invitation.invite!
      invitation.rescind!
      expect(invitation.state).to eq('rescinded')
    end

    it "sets the state to 'rescinded' from 'accepted'" do
      invitation.invite!
      invitation.accept!
      invitation.rescind!
      expect(invitation.state).to eq('rescinded')
    end

    it "does not set the state to 'rescinded' from 'pending'" do
      expect { invitation.rescind! }.to raise_error(AASM::InvalidTransition)
      expect(invitation.state).not_to eq('rescinded')
    end

    it 'tells the task it was rescinded' do
      expect(invitation.task).to receive(:invitation_rescinded)
        .with(invitation)
      invitation.invite!
      invitation.rescind!
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
        .to eq(authors_list.to_s)
    end
  end

  describe "#accept!" do
    it "sends an invitation email" do
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

  describe "#decline!" do
    it "calls the the invitation decline action callback" do
      invitation.invite!
      expect(task).to receive(:decline_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_declined).with(invitation)
      invitation.decline!
    end

    it "prevents transition to declined" do
      invitation.invite!
      expect(task).to receive(:decline_allowed?) .with(invitation).and_return(false)
      expect { invitation.decline! }.to raise_exception(AASM::InvalidTransition)
      invitation.run_callbacks(:commit)
      expect(invitation.invited?).to be_truthy
      expect(invitation.declined?).to be_falsey
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
    let(:paper) { FactoryGirl.create(:paper, :submitted_lite) }
    let(:task) { FactoryGirl.create :invitable_task, paper: paper }
    let(:no_invite_user) { FactoryGirl.create(:user) }
    let(:pending_invite_user) { FactoryGirl.create(:user) }
    let(:accepted_invite_user) { FactoryGirl.create(:user) }
    let(:declined_invite_user) { FactoryGirl.create(:user) }
    let(:all_users) do
      [no_invite_user,
       pending_invite_user,
       accepted_invite_user,
       declined_invite_user]
    end
    context 'Users with invites in various states' do
      before do
        FactoryGirl.create :invitation, :invited, task: task, invitee: pending_invite_user
        FactoryGirl.create :invitation, :accepted, task: task, invitee: accepted_invite_user
        FactoryGirl.create :invitation, :declined, task: task, invitee: declined_invite_user
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
      it "filters out the user with a declined invite" do
        expect(result).to_not include(declined_invite_user)
      end

      context "When invites belong to a previous decision" do
        before do
          paper.draft_decision.update registered_at: DateTime.now.utc,
                                      major_version: 0,
                                      minor_version: 0
          paper.decisions.create!
        end
        it "doesn't filter users based on the old invites" do
          expect(result).to contain_exactly(
            no_invite_user,
            pending_invite_user,
            declined_invite_user,
            accepted_invite_user
          )
        end
      end
    end
  end

  describe "#where_email_matches" do
    let(:emails) { ["turtle@turtles.com", "TURTLE@turtles.com"] }
    let!(:invitation_1) { create :invitation, invitee: nil, email: emails[0] }
    let!(:invitation_2) { create :invitation, invitee: nil, email: "turtle <#{emails[0]}>" }
    let!(:invitation_3) { create :invitation, invitee: nil, email: "another@email.com" }
    let!(:invitation_4) { create :invitation, invitee: nil, email: emails[1] }

    it "returns invitiations where the email matches the supplied argument" do
      emails.each do |email|
        invitations = Invitation.where_email_matches email
        expect(Invitation.count).to eq 4
        expect(invitations.map(&:id)).to contain_exactly(invitation_1.id, invitation_2.id, invitation_4.id)
      end
    end
  end

  # Explanation of terminology: https://tools.ietf.org/html/rfc2822#section-3.4
  describe "#email=" do
    let(:invitation) { build :invitation }
    let(:addr_spec) { "squirtle@gmail.com" }

    context "the email is a normal addr-spec" do
      it "sets the email as-is" do
        invitation.email = addr_spec
        expect(invitation.email).to eq addr_spec
      end
    end

    context "the email is a angle-addr" do
      let(:angle_addr) { "Squirtle Pokémon <#{addr_spec}>" }

      it "coerces the email into addr-spec" do
        invitation.email = angle_addr
        expect(invitation.email).to eq addr_spec
      end
    end

    context "the email is surrounded by whitespace" do
      let(:spacey_email) { " #{addr_spec} " }

      it "strips surrounding whitespace" do
        invitation.email = spacey_email
        expect(invitation.email).to eq addr_spec
      end
    end

    context "the email is a angle-addr with whitespace" do
      let(:angle_addr) { "Squirtle Pokémon < #{addr_spec}  >" }

      it "coerces the email into addr-spec and removes whitespace" do
        invitation.email = angle_addr
        expect(invitation.email).to eq addr_spec
      end
    end
  end

  describe "email validation" do
    let(:good_email) { "squirtle@pokemon.com" }
    let(:bad_email) { "squirtlepokemon.com" }
    let(:invitation) { build :invitation }

    it "allows any string with an at-sign" do
      expect do
        invitation.update!(email: good_email)
      end.to change { invitation.email }.to good_email
    end
    it "does not allow strings without an at-sign" do
      expect do
        invitation.update!(email: bad_email)
      end.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
