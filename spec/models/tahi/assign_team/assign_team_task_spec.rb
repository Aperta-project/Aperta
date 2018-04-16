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

describe Tahi::AssignTeam::AssignTeamTask do
  subject(:task) { described_class.new(paper: paper) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:journal) { FactoryGirl.create(:journal) }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe '#assignable_roles' do
    let(:academic_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:cover_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:handling_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:reviewer_role) { FactoryGirl.build_stubbed(:role) }

    before do
      allow(task.journal).to receive(:academic_editor_role)
        .and_return academic_editor_role

      allow(task.journal).to receive(:cover_editor_role)
        .and_return cover_editor_role

      allow(task.journal).to receive(:handling_editor_role)
        .and_return handling_editor_role

      allow(task.journal).to receive(:reviewer_role)
        .and_return reviewer_role
    end

    it 'returns roles that can be assigned thru this task' do
      expect(task.assignable_roles).to be_kind_of(Array)
    end

    it "includes the journal's academic_editor_role" do
      expect(task.assignable_roles).to \
        include(task.journal.academic_editor_role)
    end

    it "includes the journal's cover_editor_role" do
      expect(task.assignable_roles).to include(task.journal.cover_editor_role)
    end

    it "includes the journal's handling_editor_role" do
      expect(task.assignable_roles).to include \
        task.journal.handling_editor_role
    end

    it "includes the journal's reviewer_role" do
      expect(task.assignable_roles).to include \
        task.journal.reviewer_role
    end
  end

  describe '#assignments' do
    let(:academic_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:cover_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:handling_editor_role) { FactoryGirl.build_stubbed(:role) }
    let(:reviewer_role) { FactoryGirl.build_stubbed(:role) }
    let(:unsupported_role) { FactoryGirl.build_stubbed(:role) }
    let(:user) { FactoryGirl.build_stubbed(:user) }

    let!(:academic_editor_assignment) do
      FactoryGirl.create(
        :assignment,
        assigned_to: task.paper,
        role: academic_editor_role,
        user: user
      )
    end
    let!(:cover_editor_assignment) do
      FactoryGirl.create(
        :assignment,
        assigned_to: task.paper,
        role: cover_editor_role,
        user: user
      )
    end
    let!(:handling_editor_assignment) do
      FactoryGirl.create(
        :assignment,
        assigned_to: task.paper,
        role: handling_editor_role,
        user: user
      )
    end
    let!(:reviewer_assignment) do
      FactoryGirl.create(
        :assignment,
        assigned_to: task.paper,
        role: reviewer_role,
        user: user
      )
    end
    let!(:not_expected_assignment) do
      FactoryGirl.create(
        :assignment,
        assigned_to: task.paper,
        role: unsupported_role,
        user: user
      )
    end

    before do
      allow(task.journal).to receive(:academic_editor_role)
        .and_return academic_editor_role

      allow(task.journal).to receive(:cover_editor_role)
        .and_return cover_editor_role

      allow(task.journal).to receive(:handling_editor_role)
        .and_return handling_editor_role

      allow(task.journal).to receive(:reviewer_role)
        .and_return reviewer_role
    end

    it "returns assignments for this task's paper based on assignable_roles" do
      expect(task.assignments).to contain_exactly(
        academic_editor_assignment,
        cover_editor_assignment,
        handling_editor_assignment,
        reviewer_assignment
      )
    end

    it "doesn't include assignments where the role is not an assignable_role" do
      expect(task.assignments).to_not include(not_expected_assignment)
    end
  end
end
