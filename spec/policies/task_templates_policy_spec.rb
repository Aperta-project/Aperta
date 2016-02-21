require 'rails_helper'

describe TaskTemplatesPolicy do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:manuscript_manager_template) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }
  let(:phase_template) { FactoryGirl.create(:phase_template, manuscript_manager_template: manuscript_manager_template) }
  let(:task_template) { FactoryGirl.build(:task_template, phase_template: phase_template, journal_task_type: journal.journal_task_types.first) }
  let(:policy) { TaskTemplatesPolicy.new(current_user: user, task_template: task_template) }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }

    include_examples "person who can administer task templates"
  end

  context "non admin who does not administer the journal" do
    let(:user) { FactoryGirl.create(:user) }

    include_examples "person who cannot administer task templates"
  end

  context "user who administers the journal" do
    let(:user) { FactoryGirl.create(:user) }
    let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }

    before do
      assign_journal_role(journal, user, :admin)
    end

    include_examples "person who can administer task templates"
  end
end
