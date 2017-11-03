# coding: utf-8
require 'rails_helper'

describe User do
  it "will be valid with default factory data" do
    expect(build(:user)).to be_valid
  end

  describe '.site_admins' do
    let!(:user1) { FactoryGirl.create(:user, :site_admin) }
    let!(:user2) { FactoryGirl.create(:user) }

    it 'includes admin users only' do
      site_admins = User.site_admins
      expect(site_admins).to include user1
      expect(site_admins).not_to include user2
    end
  end

  describe '#created_papers_for_journal' do
    subject(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
    let!(:other_user) { FactoryGirl.create(:user) }

    let!(:created_paper_1) do
      FactoryGirl.create(:paper, journal: journal, creator: user)
    end
    let!(:created_paper_2) do
      FactoryGirl.create(:paper, journal: journal, creator: user)
    end
    let!(:not_my_paper) do
      FactoryGirl.create(:paper, journal: journal, creator: other_user)
    end

    it 'returns papers where this user is its creator' do
      created_papers = user.created_papers_for_journal(journal)
      expect(created_papers).to contain_exactly(
        created_paper_1,
        created_paper_2
      )
    end

    it 'does not return other papers' do
      created_papers = user.created_papers_for_journal(journal)
      expect(created_papers).to_not include(not_my_paper)
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
      expect(user).to be_valid
    end

    it 'validates a username with dashes' do
      user = FactoryGirl.build(:user, username: 'blah-blah')
      expect(user).to be_valid
    end

    it 'validates against blank username' do
      user = FactoryGirl.build(:user, username: '')
      expect(user).to_not be_valid
      expect(user.errors.to_a).to contain_exactly("Username can't be blank")
    end

    it 'allows a username with periods' do
      user = FactoryGirl.build(:user, username: 'blah.blah')
      expect(user).to be_valid
    end

    it 'allows a username with with utf-8' do
      user = FactoryGirl.build(:user, username: 'bláh blàh')
      expect(user).to be_valid

      user = FactoryGirl.build(:user, username: '😻')
      expect(user).to be_valid

      user = FactoryGirl.build(:user, username: 'Лев Никола́евич Толсто́й')
      expect(user).to be_valid

      user = FactoryGirl.build(:user, username: '李尧棠')
      expect(user).to be_valid
    end
  end

  describe '#tasks' do
    subject(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:journal) { FactoryGirl.create(:journal, :with_task_participant_role) }
    let!(:participating_task) { FactoryGirl.create(:ad_hoc_task, :with_stubbed_associations, paper: paper) }
    let!(:not_participating_task) { FactoryGirl.create(:ad_hoc_task, :with_stubbed_associations, paper: paper) }
    let!(:other_role) { FactoryGirl.create(:role) }

    before do
      participating_task.add_participant user
      not_participating_task.assignments.create!(user: user, role: other_role)
    end

    it 'returns tasks the user is assigned to as a participant' do
      expect(user.tasks).to contain_exactly(participating_task)
    end

    it 'does not return tasks the user is assigned with another role' do
      expect(user.tasks).to_not include(not_participating_task)
    end
  end

  describe '#invitations_from_draft_decision' do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, :submitted_lite) }
    let(:decision) { paper.draft_decision }
    let(:task) { FactoryGirl.create :invitable_task, paper: paper }
    let(:another_task) { FactoryGirl.create :invitable_task, paper: paper }
    let(:inv1) { FactoryGirl.create :invitation, task: task, invitee: user, decision: decision }
    let(:inv2) { FactoryGirl.create :invitation, task: task, invitee: user, decision: decision }
    let(:another_task_invitation) { FactoryGirl.create :invitation, task: task, invitee: user, decision: decision }

    it 'returns invitiations from multiple tasks' do
      inv1.invite!
      another_task_invitation.invite!
      expect(user.invitations_from_draft_decision)
        .to contain_exactly(inv1, another_task_invitation)
    end

    it 'returns invitations from the latest revision cycle' do
      inv1.invite!
      expect(user.invitations_from_draft_decision).to contain_exactly(inv1)

      # complete the old decision and create a new one
      decision.update!(major_version: 0, minor_version: 0)
      paper.new_draft_decision!

      inv2.invite!
      expect(user.reload.invitations_from_draft_decision).to contain_exactly(inv2)
    end

    context 'invitation without a decision' do
      let(:paper) { FactoryGirl.create :paper }
      let(:invitation) { FactoryGirl.create :invitation, paper: paper, invitee: user, decision: nil }

      it 'returns invitations with decisions from the latest revision cycle' do
        expect(invitation.decision).to be_nil
        expect(user.invitations_from_draft_decision).to be_empty
      end
    end
  end

  describe ".new_with_session" do
    let(:personal_details) { { "personal_details" => { "given_names" => "Joe", "family_name" => "Smith" } } }
    let(:orcid_session) do
      { "devise.provider" => { "orcid" => { "uid" => "myuid",
                                            "info" => { "orcid_bio" => personal_details } } } }
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

  describe '.assigned_to_journal' do
    let(:journal) { create(:journal, :with_admin_roles) }
    it 'finds users who are assigned to the journal, ordered by name' do
      [['A', 'B'], ['B', 'A'], ['A', 'A']].map do |(first_name, last_name)|
        create(:user, first_name: first_name, last_name: last_name).tap do |user|
          assign_journal_role(journal, user, :admin)
        end
      end

      expect(User.assigned_to_journal(journal.id)
        .pluck(:first_name, :last_name)).to match_array(
          [['A', 'A'], ['B', 'A'], ['A', 'B']]
        )
    end

    it "doesn't return users who aren't assigned to that journal" do
      create(:user, first_name: "not", last_name: "assigned")

      other_journal = create(:journal, :with_admin_roles)
      create(:user, first_name: "John", last_name: "Doe").tap do |user|
        assign_journal_role(other_journal, user, :admin)
      end

      expect(User.assigned_to_journal(journal.id)).to eq([])
    end
  end

  describe ".fuzzy_search" do
    let!(:user)  { create(:user, first_name: 'David', last_name: 'Wang', email: 'dwang@gmail.com', username: 'dwangpwn') }
    let!(:user2) { create(:user, first_name: 'David', last_name: 'Chan', email: 'dchan@gmail.com', username: 'dchanpwn') }

    it "searches by user's first_name and last_name" do
      expect(User.fuzzy_search(user.first_name).size).to eq 2
      expect(User.fuzzy_search(user.last_name).size).to eq 1
      expect(User.fuzzy_search(user.last_name.downcase).first.id).to eq user.id
      expect(User.fuzzy_search("#{user.first_name} #{user.last_name.downcase}").first.id).to eq user.id
    end

    it "searches by user's email" do
      user3 = create :user, first_name: 'Jeffrey', last_name: 'Gray', email: 'jef+1@example.com'
      user4 = create :user, first_name: 'Jeffrey', last_name: 'Gray', email: 'jef+2@example.com'
      expect(User.fuzzy_search(user.email).first.id).to eq user.id
      expect(User.fuzzy_search(user.email).size).to eq 1
    end

    it "searches by user's username" do
      expect(User.fuzzy_search(user.username).first.id).to eq user.id
    end

    it "searches by multiple attributes at once" do
      expect(User.fuzzy_search("#{user.first_name} #{user.username}").first.id).to eq user.id
    end

    it "searches attributes with accent marks" do
      expect(User.fuzzy_search("davïd").size).to eq 2
    end
  end

  describe "#journal_admin?" do
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:journal) { FactoryGirl.create(:journal, :with_admin_roles) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:administer_journal_permission) do
      FactoryGirl.create(
        :permission,
        action: :administer,
        applies_to: Journal.name,
        states: [PermissionState.wildcard]
      )
    end

    before do
      journal.staff_admin_role.permissions << administer_journal_permission
    end

    it "returns true if user is an admin for a given journal" do
      user.assign_to!(assigned_to: journal, role: journal.staff_admin_role)
      expect(user.journal_admin?(journal)).to be true
    end

    it "returns false if user is not an admin for a given journal" do
      expect(user.journal_admin?(journal)).to be false
    end
  end

  describe "#assign_to!" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal) }
    let!(:role) { FactoryGirl.create(:role, name: 'role', journal: journal) }
    let!(:user_role) { FactoryGirl.create(:role, name: 'user role', journal: nil) }
    # role with same name on a different journal
    let!(:decoy_journal) { FactoryGirl.create(:journal) }
    let!(:decoy_role) { FactoryGirl.create(:role, name: 'role', journal: decoy_journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }

    shared_examples_for 'assigning to a role' do
      it 'can be used to assign a role on a journal' do
        expect { user.assign_to!(assigned_to: journal, role: role_arg) }
          .to change { user.roles.count }.by 1
        expect(user).to have_role(role, journal)
        expect(user).not_to have_role(decoy_role, journal)
        expect(user).not_to have_role(decoy_role, decoy_journal)
      end

      it 'can be used to assign a role on a paper' do
        expect { user.assign_to!(assigned_to: paper, role: role_arg) }
          .to change { user.roles.count }.by 1
        expect(user).to have_role(role, paper)
        expect(user).not_to have_role(decoy_role, paper)
      end

      it 'can be used to assign a role on a task' do
        expect { user.assign_to!(assigned_to: task, role: role_arg) }
          .to change { user.roles.count }.by 1
        expect(user).to have_role(role, task)
        expect(user).not_to have_role(decoy_role, task)
      end

      it 'should do nothing if the user is already assigned' do
        expect(user).not_to have_role(role, paper)
        expect { user.assign_to!(assigned_to: paper, role: role_arg) }
          .to change { user.roles.count }.by 1
        expect(user).to have_role(role, paper)
        expect { user.assign_to!(assigned_to: paper, role: role_arg) }
          .not_to change { user.roles.count }
      end
    end

    context 'when supplying a role name' do
      let(:role_arg) { 'role' }

      it_behaves_like 'assigning to a role'

      it 'raises an error for a role that does not exist' do
        expect { user.assign_to!(assigned_to: paper, role: 'Chief Pirate') }.to \
          raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'raises an error if the thing passed in does not have a `journal` method' do
        expect { user.assign_to!(assigned_to: user, role: 'Chief Pirate') }.to \
          raise_exception(/Expected.*to be a journal or respond to journal method/)
      end
    end

    context 'when supplying role' do
      let(:role_arg) { role }

      it_behaves_like 'assigning to a role'

      it 'can be used to assign a role to a thing that does not implement the `journal` method' do
        user.assign_to!(assigned_to: user, role: user_role)
        expect(user).to have_role(user_role, user)
      end
    end
  end

  describe "#unassign_from!" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
    let!(:role) { FactoryGirl.create(:role, name: 'role', journal: journal) }
    let!(:user_role) { FactoryGirl.create(:role, name: 'user role', journal: nil) }
    # role with same name on a different journal
    let!(:decoy_journal) { FactoryGirl.create(:journal) }
    let!(:decoy_role) { FactoryGirl.create(:role, name: 'role', journal: decoy_journal) }

    shared_examples_for 'resigning from a role' do
      it 'can be used to resign a role on a journal' do
        FactoryGirl.create(:assignment,
          user: user,
          role: role,
          assigned_to: journal)
        expect(user).to have_role(role, journal)
        expect { user.resign_from!(assigned_to: journal, role: role_arg) }
          .to change { user.roles.count }.by(-1)
        expect(user).not_to have_role(role, journal)
      end

      it 'can be used to resign a role on a paper' do
        FactoryGirl.create(:assignment,
          user: user,
          role: role,
          assigned_to: paper)
        expect(user).to have_role(role, paper)
        expect { user.resign_from!(assigned_to: paper, role: role_arg) }
          .to change { user.roles.count }.by(-1)
        expect(user).not_to have_role(role, paper)
      end

      it 'can be used to resign a role on a task' do
        FactoryGirl.create(:assignment,
          user: user,
          role: role,
          assigned_to: task)
        expect(user).to have_role(role, task)
        expect { user.resign_from!(assigned_to: task, role: role_arg) }
          .to change { user.roles.count }.by(-1)
        expect(user).not_to have_role(role, task)
      end

      it 'should do nothing if the user is already not assigned' do
        expect(user).not_to have_role(role, journal)
        expect { user.resign_from!(assigned_to: journal, role: role_arg) }
          .not_to change { user.roles.count }
        expect(user).not_to have_role(role, journal)
      end
    end

    context 'when supplying a role name' do
      let(:role_arg) { 'role' }

      it_behaves_like 'resigning from a role'

      it 'raises an error for a role that does not exist' do
        expect { user.resign_from!(assigned_to: paper, role: 'Chief Pirate') }.to \
          raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'raises an error if the thing passed in does not have a `journal` method' do
        expect { user.resign_from!(assigned_to: user, role: 'Chief Pirate') }.to \
          raise_exception(/Expected.*to be a journal or respond to journal method/)
      end
    end

    context 'when supplying role' do
      let(:role_arg) { role }

      it_behaves_like 'resigning from a role'

      it 'can be used to resign from role to a thing that does not implement the `journal` method' do
        FactoryGirl.create(:assignment,
          user: user,
          role: user_role,
          assigned_to: user)
        expect { user.resign_from!(assigned_to: user, role: user_role) }
          .to change { user.roles.count }.by(-1)
        expect(user).not_to have_role(user_role, user)
      end
    end
  end

  describe "#create" do
    describe "roles" do
      let(:user) { User.create! attributes_for(:user) }
      let!(:user_role) { Role.where(name: Role::USER_ROLE).first_or_create! }

      it "should create a user record with the User role assigned" do
        expect(user_role).to be_present
        expect(user).to have_role Role::USER_ROLE
      end
    end

    describe "invitations" do
      let!(:orphan_invite) { FactoryGirl.create(:invitation, invitee: nil, email: "steve@example.com") }
      let!(:other_invite) { FactoryGirl.create(:invitation, invitee: nil) }

      it "assigns invitations to the user" do
        user_attrs = attributes_for(:user)
        user_attrs[:email] = 'steve@example.com'
        user = User.create!(user_attrs)
        expect(orphan_invite.reload.invitee_id).to be(user.id)
        expect(other_invite.reload.invitee).to be_nil
      end
    end
  end

  describe '.auto_generate_username' do
    let(:user) { User.new(first_name: 'foo', last_name: 'bar') }
    let(:random_string) { 'abc123' }
    it 'sets the user name to the first initial, last name and random string' do
      expect(SecureRandom).to receive(:hex).with(6).and_return(random_string)
      user.auto_generate_username
      expect(user.username).to eq("#{user.first_name[0]}_#{user.last_name}_#{random_string}")
    end
  end
end
