require 'rails_helper'

describe Tahi::AssignTeam::AssignTeamTask do
  subject(:task) { described_class.new(paper: paper) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:journal) { FactoryGirl.create(:journal) }

  describe '#assignable_roles' do
    let(:cover_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:handling_editor_role) { FactoryGirl.build_stubbed(:role) }

    before do
      allow(task.journal).to receive(:handling_editor_role)
        .and_return handling_editor_role

      allow(task.journal).to receive(:cover_editor_role)
        .and_return cover_editor_role
    end

    it 'returns roles that can be assigned thru this task' do
      expect(task.assignable_roles).to be_kind_of(Array)
    end

    it "includes the journal's handling_editor_role" do
      expect(task.assignable_roles).to include(task.journal.handling_editor_role)
    end

    it "includes the journal's cover_editor_role" do
      expect(task.assignable_roles).to include(task.journal.cover_editor_role)
    end
  end

  describe '#assignments' do
    let(:cover_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:handling_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:unsupported_role) { FactoryGirl.build_stubbed(:role) }
    let(:user) { FactoryGirl.build_stubbed(:user) }

    let(:expected_assignment_1) do
      FactoryGirl.create(:assignment, assigned_to: task.paper, role: cover_editor_role, user: user)
    end
    let(:expected_assignment_2) do
      FactoryGirl.create(:assignment, assigned_to: task.paper, role: handling_editor_role, user: user)
    end
    let(:not_expected_assignment) do
      FactoryGirl.create(:assignment, assigned_to: task.paper, role: unsupported_role, user: user)
    end

    before do
      allow(task.journal).to receive(:handling_editor_role)
        .and_return handling_editor_role

      allow(task.journal).to receive(:cover_editor_role)
        .and_return cover_editor_role
    end

    it "returns the assignments to this task's paper based on the assignable_roles" do
      expect(task.assignments).to contain_exactly(
        expected_assignment_1,
        expected_assignment_2
      )
    end

    it "does not include assignments where the role is not an assignable_role" do
      expect(task.assignments).to_not include(not_expected_assignment)
    end
  end

end
