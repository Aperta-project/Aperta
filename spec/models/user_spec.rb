require 'rails_helper'

describe User do
  it "will be valid with default factory data" do
    expect(build(:user)).to be_valid
  end

  describe "scopes" do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    describe ".admins" do
      it "includes admin users only" do
        user1.update! site_admin: true
        admins = User.site_admins
        expect(admins).to include user1
        expect(admins).not_to include user2
      end
    end
  end

  describe "#possible_flows" do
    it "returns all flows assigned to the user's roles" do
      role = FactoryGirl.create(:role)
      flow = FactoryGirl.create(:flow, role: role)
      user = FactoryGirl.create(:user)
      user.roles << role

      expect(user.possible_flows).to include(flow)
    end
  end

  describe "#full_name" do
    it "returns the user's first and last name" do
      user = User.new first_name: 'Mihaly', last_name: 'Csikszentmihalyi'
      expect(user.full_name).to eq 'Mihaly Csikszentmihalyi'
    end
  end

  describe '#username' do
    it 'validates username' do
      user = FactoryGirl.build(:user, username: 'mihaly')
      expect(user.save!).to eq true
    end

    it 'validates against blank username' do
      user = FactoryGirl.build(:user, username: '')
      expect(user).to_not be_valid
      expect(user.errors.size).to eq 2
      expect(user.errors.to_a.first).to eq "Username can't be blank"
      expect(user.errors.to_a.last).to eq "Username is invalid"
    end

    it 'validates against username with dashes' do
      user = FactoryGirl.build(:user, username: 'blah-blah')
      expect(user).to_not be_valid
      expect(user.errors.size).to eq 1
      expect(user.errors.first).to eq [:username, "is invalid"]
    end
  end

  describe '#invitations_from_latest_revision' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      paper = FactoryGirl.create :paper
      paper.decisions.create!
    end

    it 'returns invitations from the latest revision cycle' do
      phase = FactoryGirl.create :phase
      decision = phase.paper.decisions.create!
      task = FactoryGirl.create :invitable_task, phase: phase
      inv1 = FactoryGirl.create :invitation, task: task, invitee: user, decision: decision
      inv2 = FactoryGirl.create :invitation, task: task, invitee: user, decision: decision
      inv1.invite!
      inv2.invite!
      expect(user.invitations_from_latest_revision).to match_array [inv1, inv2]
      decision = phase.paper.decisions.create!
      inv3 = FactoryGirl.create :invitation, task: task, invitee: user, decision: decision
      inv3.invite!
      expect(user.reload.invitations_from_latest_revision).to match_array [inv3]
    end

    context 'invitation without a decision' do
      before do
        task = FactoryGirl.create :invitable_task
        invitation = FactoryGirl.create :invitation, task: task, invitee: user
        # force-delete the decision
        invitation.decision.destroy!
      end

      it 'returns invitations with decisions from the latest revision cycle' do
        expect(user.invitations_from_latest_revision).to be_empty
      end
    end
  end

  describe ".new_with_session" do
    let(:personal_details) { {"personal_details" => {"given_names" => "Joe", "family_name" => "Smith"}} }
    let(:orcid_session) do
      {"devise.provider" => {"orcid" => {"uid" => "myuid",
                                         "info" => {"orcid_bio" => personal_details}}}}
    end

    it "will prefill new user form with orcid info" do
      user = User.new_with_session(nil, orcid_session)
      expect(user.first_name).to eq('Joe')
      expect(user.last_name).to eq('Smith')
    end

    it "will auto generate a password" do
      user = User.new_with_session(nil, orcid_session)
      expect(user.password).not_to be_empty
    end
  end

  context "password authentication" do
    let(:user) { User.new }
    before { expect(Rails.configuration).to receive(:password_auth_enabled).and_return(enabled) }

    context "is enabled" do
      let(:enabled) { true }

      specify { expect(user.password_required?).to eq(enabled) }
      specify { expect(user.auto_generate_password).to be_present }
    end

    context "is disabled" do
      let(:enabled) { false }

      specify { expect(user.password_required?).to eq(enabled) }
      specify { expect(user.auto_generate_password).to be_blank }
    end
  end


  describe ".fuzzy_search" do
    it "searches by user's first_name and last_name" do
      user = create :user, first_name: 'David', last_name: 'Wang'

      expect(User.fuzzy_search(user.first_name).size).to eq 1
      expect(User.fuzzy_search(user.first_name.downcase).first.id).to eq user.id
      expect(User.fuzzy_search(user.last_name.downcase).first.id).to eq user.id
      expect(User.fuzzy_search("#{user.first_name} #{user.last_name.downcase}").first.id).to eq user.id
    end

    it "searches by user's email" do
      user = create :user, email: 'dwang@gmail.com'
      expect(User.fuzzy_search(user.email).first.id).to eq user.id
    end

    it "searches by user's username" do
      user = create :user, username: 'dwangpwn'
      expect(User.fuzzy_search(user.username).first.id).to eq user.id
    end

    it "searches by multiple attributes at once" do
      user = create :user, username: 'blah', first_name: 'David', last_name: 'Wang', email: 'dwang@gmail.com'
      expect(User.fuzzy_search("#{user.first_name} #{user.username}").first.id).to eq user.id
    end

    it "searches attributes with accent marks" do
      user = create :user, first_name: 'David', last_name: 'Wang'
      expect(User.fuzzy_search("davïd").first.id).to eq user.id
    end
  end

  describe "#journal_admin?" do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:journal) { paper.journal }
    let(:journal_admin) { FactoryGirl.create(:user) }
    let!(:role) { assign_journal_role(journal, journal_admin, :admin) }
    let(:regular_user) { FactoryGirl.create(:user) }

    it "returns true if user is an admin for a given journal" do
      expect(journal_admin.journal_admin? journal).to be true
    end

    it "returns false if user is not an admin for a given journal" do
      expect(regular_user.journal_admin? journal).to be false
    end
  end
end
