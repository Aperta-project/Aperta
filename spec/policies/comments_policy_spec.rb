require 'spec_helper'

describe CommentsPolicy do
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let(:journal) { FactoryGirl.create(:journal, papers: [paper]) }
  let(:task) { paper.tasks.first }
  let(:policy) { CommentsPolicy.new(current_user: user, task: task) }

  context "site admin" do
    let(:user) { FactoryGirl.create(:user, :admin) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
  end

  context "paper collaborator" do
    let!(:paper_role) { create(:paper_role, :collaborator, user: user, paper: paper) }
    let(:task) { paper.tasks.metadata.first }
    let(:user) { FactoryGirl.create(:user) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }

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
    it { expect(policy.create?).to be(true) }
  end

  context "user with can_view_assigned_manuscript_managers on this journal and is assigned to the paper." do
    let(:journal_role) { FactoryGirl.create(:role, journal: journal, can_view_assigned_manuscript_managers: true) }
    let(:user) do
      user = FactoryGirl.create(:user)
      user.roles << journal_role
      user
    end

    before do
      FactoryGirl.create(:paper_role, :editor, user: user, paper: paper)
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
  end
end
