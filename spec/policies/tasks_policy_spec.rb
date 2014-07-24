require 'spec_helper'

describe TasksPolicy do
  let(:policy) { TasksPolicy.new(current_user: user, task: task) }
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:task) { paper.tasks.first }
  let(:journal) { FactoryGirl.create(:journal, papers: [paper]) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }
    let(:task) { paper.tasks.metadata.first }
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.edit?).to be(true) }
    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.upload?).to be(true) }

    context "on a non metadata task" do
      let(:task) { paper.tasks.where.not(type: Task.metadata_types).first }
      it { expect(policy.show?).to be(false) }
    end
  end

  context "user with can_view_all_manuscript_managers on this journal" do
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal), ],
      )
    end

    it { expect(policy.show?).to be(true) }
  end

  context "user no role" do
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.show?).to be(false) }
  end

  context "user with role on different journal" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:user) do
      FactoryGirl.create(
        :user,
        roles: [ FactoryGirl.create(:role, :admin, journal: journal) ],
      )
      end

    it { expect(policy.show?).to be(false) }
  end
end
