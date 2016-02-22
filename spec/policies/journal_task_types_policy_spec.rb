require 'rails_helper'

describe JournalTaskTypesPolicy do
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:journal_task_type) { FactoryGirl.create(:journal_task_type, old_role: 'author', title: 'Awesome Card', journal: journal) }
  let(:policy) { JournalTaskTypesPolicy.new(current_user: user, journal_task_type: journal_task_type) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    it { expect(policy.update?).to be(true) }
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.update?).to be(false) }
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    it { expect(policy.update?).to be(true) }
  end
end
