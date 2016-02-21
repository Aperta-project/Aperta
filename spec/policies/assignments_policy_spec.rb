require 'rails_helper'

describe AssignmentsPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:policy) { AssignmentsPolicy.new(current_user: user, paper: paper) }
  let(:old_role) { FactoryGirl.create(:old_role, journal: journal) }

  before do
    @paper_role = PaperRole.create! old_role: old_role.name, user: user, paper: paper
  end

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    it "can modify everything" do
      expect(policy.can_manage_manuscript?).to be(true)
      expect(policy.index?).to be(true)
      expect(policy.create?).to be(true)
      expect(policy.destroy?).to be(true)
    end
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }

    it "can modify everything" do
      expect(policy.can_manage_manuscript?).to be(false)
      expect(policy.index?).to be(false)
      expect(policy.create?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it "can modify everything" do
      expect(policy.can_manage_manuscript?).to be(true)
      expect(policy.index?).to be(true)
      expect(policy.create?).to be(true)
      expect(policy.destroy?).to be(true)
    end
  end
end
